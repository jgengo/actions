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
      }
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
      
      // Read screenshot as base64
      const imageBuffer = fs.readFileSync(outputPath);
      const base64Image = imageBuffer.toString('base64');
      
      // Create comment with image
      await octokit.rest.issues.createComment({
        owner,
        repo,
        issue_number: prNumber,
        body: `## PR Screenshot\n![Screenshot](data:image/png;base64,${base64Image})`
      });
      
      core.info('Posted screenshot to PR comment');
    }
    
    core.setOutput('screenshot-path', outputPath);
  } catch (error) {
    core.setFailed(`Action failed with error: ${error.message}`);
  }
}

run();
