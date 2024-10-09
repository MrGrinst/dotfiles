#!/usr/bin/env npx tsx

import { execSync } from "child_process";
import readline from "readline";
import { LinearClient } from "@linear/sdk";
import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.join(__dirname, ".envrc") });

const IN_PROGRESS_STATE = "In Progress (Dev)";
const PROJECT_LABEL_MAPPING: Record<string, string> = {
  "aquifer-server": "aquifer-api",
  "well-web": "bible-well-web",
  "content-manager-web": "admin-web",
};

const ADDITIONAL_LABELS = ["Bug", "Dev Task", "Improvement"];

const linearClient = new LinearClient({ apiKey: process.env.LINEAR_API_KEY });

function getLatestCommitInfo() {
  const commitTitle = execSync("git log -1 --pretty=%s").toString().trim();
  const commitDescription = execSync("git log -1 --pretty=%b")
    .toString()
    .trim();
  return { commitTitle, commitDescription };
}

function getCurrentProjectDirectory() {
  return execSync("pwd").toString().trim().split("/").pop() || "";
}

async function promptForAdditionalLabel(): Promise<string> {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stderr,
  });

  return new Promise((resolve) => {
    const prompt = `Select an additional label:\n${ADDITIONAL_LABELS.map(
      (label, index) => `${index + 1}. ${label}`,
    ).join("\n")}\nEnter the number: `;

    rl.question(prompt, (answer: string) => {
      rl.close();
      const selectedIndex = parseInt(answer.trim(), 10) - 1;
      if (selectedIndex >= 0 && selectedIndex < ADDITIONAL_LABELS.length) {
        const selectedLabel = ADDITIONAL_LABELS[selectedIndex];
        resolve(selectedLabel);
      } else {
        console.log("Invalid selection. Please choose a valid number.");
        resolve(promptForAdditionalLabel());
      }
    });
  });
}

async function createLinearTicketAndBranch() {
  const { commitTitle, commitDescription } = getLatestCommitInfo();
  const projectDirectory = getCurrentProjectDirectory();

  const teams = (await linearClient.teams()).nodes;
  const cycles = (await linearClient.cycles({ first: 100 })).nodes;
  const labels = (await linearClient.issueLabels()).nodes;
  const states = (await linearClient.workflowStates()).nodes;
  const me = await linearClient.viewer;
  const team = teams[0];
  const cycle = cycles.find(
    (c) => !c.completedAt && c.startsAt.getTime() < Date.now(),
  );
  const inProgressState = states.find(
    (s) => s.name.toLowerCase() === IN_PROGRESS_STATE.toLowerCase(),
  );

  const projectLabelName =
    PROJECT_LABEL_MAPPING[projectDirectory] || projectDirectory;
  const projectLabel = labels.find(
    (label) => label.name.toLowerCase() === projectLabelName.toLowerCase(),
  );

  const additionalLabelName = await promptForAdditionalLabel();
  const additionalLabel = labels.find(
    (label) => label.name.toLowerCase() === additionalLabelName.toLowerCase(),
  );

  const labelIds = [projectLabel?.id, additionalLabel?.id].filter(
    Boolean,
  ) as string[];

  if (team && me && cycle && inProgressState) {
    const result = await linearClient.createIssue({
      assigneeId: me.id,
      cycleId: cycle.id,
      labelIds,
      teamId: team.id,
      title: commitTitle,
      description: commitDescription,
      stateId: inProgressState.id,
    });

    const newIssue = await result.issue;

    if (newIssue?.branchName) {
      console.log(newIssue.branchName);
      return;
    }
  }

  process.exit(1);
}

createLinearTicketAndBranch();
