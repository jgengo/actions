const core = require('@actions/core');
const github = require('@actions/github');
const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

async function run() {
  try {
    // Get inputs
    const url = core.getInput('url', { required: true });
    const waitForSelector = core.getInput('wait-for-selector') || 'body';
    const viewportWidth = parseInt(core.getInput('viewport-width') || '1280');
    const viewportHeight = parseInt(core.getInput('viewport-height') || '800');
    const outputPath = core.getInput('output-path') || './screenshot.png';
    const authToken = core.getInput('auth-token');
    const commentOnPr = core.getInput('comment-on-pr') === 'true';
    const fullPage = core.getInput('full-page') === 'true';

    core.info(`Taking screenshot of ${url}`);
    
    // Launch browser
    const browser = await puppeteer.launch({
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
      defaultViewport: {
        width: viewportWidth,
        height: viewportHeight
      },
      headless: "new"
    });
    
    const page = await browser.newPage();
    
    // Navigate to URL
    await page.goto(url, { waitUntil: 'networkidle0' });
    
    // Wait for selector
    await page.waitForSelector(waitForSelector, { visible: true });
    
    // Ensure directory exists
    const outputDir = path.dirname(outputPath);
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }
    
    // Take screenshot
    await page.screenshot({
      path: outputPath,
      fullPage: fullPage
    });
    
    await browser.close();
    
    core.info(`Screenshot saved to ${outputPath}`);
    
    // Comment on PR if enabled
    if (commentOnPr && github.context.payload.pull_request) {
      const octokit = github.getOctokit(authToken);
      const { owner, repo } = github.context.repo;
      const prNumber = github.context.payload.pull_request.number;
      
      // Get the current commit SHA
      const sha = github.context.sha;
      const runId = process.env.GITHUB_RUN_ID;
      
      // Upload the screenshot as a commit comment
      const stats = fs.statSync(outputPath);
      const fileSizeInBytes = stats.size;
      const fileStream = fs.createReadStream(outputPath);
      
      try {
        // Create screenshots directory path for the upload
        const screenshotPath = `screenshots/${sha}-${path.basename(outputPath)}`;
        
        // Upload the asset to the current repo
        const uploadResponse = await octokit.rest.repos.createOrUpdateFileContents({
          owner,
          repo,
          path: screenshotPath,
          message: `Add screenshot for PR #${prNumber}`,
          content: fs.readFileSync(outputPath).toString('base64'),
          branch: github.context.payload.pull_request ? github.context.payload.pull_request.base.ref : github.context.ref.replace('refs/heads/', '')
        });
        
        // Get the raw URL to the file
        const screenshotUrl = uploadResponse.data.content.download_url;
        
        // Create comment with image link
        await octokit.rest.issues.createComment({
          owner,
          repo,
          issue_number: prNumber,
          body: `## PR Screenshot\n![Screenshot](${screenshotUrl})`
        });
        
        core.info(`Posted screenshot to PR comment: ${screenshotUrl}`);
      } catch (error) {
        core.warning(`Failed to upload screenshot: ${error.message}`);
        
        // Fallback: Comment with a link to the Actions run
        const repoUrl = `https://github.com/${owner}/${repo}`;
        const actionsUrl = `${repoUrl}/actions/runs/${runId}`;
        
        await octokit.rest.issues.createComment({
          owner,
          repo,
          issue_number: prNumber,
          body: `## PR Screenshot\nScreenshot was captured but couldn't be uploaded directly. You can find it in the [Actions run](${actionsUrl}).`
        });
      }
    }
    
    core.setOutput('screenshot-path', outputPath);
  } catch (error) {
    core.setFailed(`Action failed with error: ${error.message}`);
  }
}

run();
