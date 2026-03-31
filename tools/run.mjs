#!/usr/bin/env node

import { spawn } from "node:child_process";
import { existsSync } from "node:fs";
import path from "node:path";
import process from "node:process";

const rootDir = process.cwd();
const androidDir = path.join(rootDir, "android");
const isWindows = process.platform === "win32";

const flutterExecutable = process.env.FLUTTER_BIN || "flutter";
const gradleWrapper = path.join(androidDir, isWindows ? "gradlew.bat" : "gradlew");

const args = process.argv.slice(2);
const command = args[0] || "help";
const forwardedArgs = args.slice(1);

const commandMap = {
  help: () => printHelp(),
  bootstrap: () => runSequence([() => flutter(["pub", "get"]), () => flutter(["doctor"])]),
  "env-check": () =>
    runSequence([
      () => raw("node", ["--version"]),
      () => raw("npm", ["--version"]),
      () => raw("java", ["-version"]),
      () => flutter(["--version"]),
      () => gradle(["--version"])
    ]),
  doctor: () => flutter(["doctor", "-v"]),
  clean: () => flutter(["clean"]),
  deps: () => flutter(["pub", "get"]),
  "deps-upgrade": () => flutter(["pub", "upgrade"]),
  analyze: () => flutter(["analyze"]),
  test: () => flutter(["test"]),
  "android-sync": () =>
    runSequence([
      () => flutter(["pub", "get"]),
      () => gradle(["help"])
    ]),
  "android-clean": () =>
    runSequence([
      () => flutter(["clean"]),
      () => gradle(["clean"])
    ]),
  "build-apk-debug": () => flutter(["build", "apk", "--debug"]),
  "build-apk-release": () => flutter(["build", "apk", "--release"]),
  "build-apk-split": () => flutter(["build", "apk", "--release", "--split-per-abi"]),
  "build-appbundle-release": () => flutter(["build", "appbundle", "--release"]),
  "analyze-size": () => flutter(["build", "apk", "--release", "--analyze-size"]),
  flutter: () => flutter(forwardedArgs),
  gradle: () => gradle(forwardedArgs)
};

if (!existsSync(path.join(rootDir, "pubspec.yaml"))) {
  console.error("This command must be run from the Flutter project root.");
  process.exit(1);
}

if (!commandMap[command]) {
  console.error(`Unknown command: ${command}`);
  printHelp();
  process.exit(1);
}

await commandMap[command]();

function flutter(commandArgs) {
  return raw(flutterExecutable, commandArgs);
}

function gradle(commandArgs) {
  if (!existsSync(gradleWrapper)) {
    console.error(`Gradle wrapper not found at ${gradleWrapper}`);
    process.exit(1);
  }

  return raw(gradleWrapper, commandArgs, { cwd: androidDir });
}

function raw(executable, commandArgs, options = {}) {
  return runProcess(executable, commandArgs, options);
}

async function runSequence(steps) {
  for (const step of steps) {
    await step();
  }
}

function runProcess(executable, commandArgs, options = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(executable, commandArgs, {
      cwd: options.cwd || rootDir,
      stdio: "inherit",
      shell: false,
      env: process.env
    });

    child.on("error", (error) => {
      if (error.code === "ENOENT") {
        console.error(`Missing executable: ${executable}`);
      } else {
        console.error(error.message);
      }
      reject(error);
    });

    child.on("close", (code) => {
      if (code === 0) {
        resolve();
        return;
      }

      process.exit(code ?? 1);
    });
  });
}

function printHelp() {
  console.log(`
SmartCampus tooling commands

Bootstrap and checks
  npm run bootstrap
  npm run env:check
  npm run doctor

Flutter workflow
  npm run deps
  npm run analyze
  npm run test
  npm run run
  npm run run:android

Android workflow
  npm run android:sync
  npm run android:clean
  npm run android:devices
  npm run android:lint
  npm run android:install:debug
  npm run android:build
  npm run android:build:debug
  npm run android:build:split
  npm run android:bundle
  npm run android:analyze-size

Gradle workflow
  npm run gradle:clean
  npm run gradle:tasks
  npm run gradle:assemble:debug
  npm run gradle:assemble:release
  npm run gradle:bundle:release
  npm run gradle:dependencies
  npm run gradle:signing-report

Pass-through commands
  npm run flutter -- <flutter arguments>
  npm run gradle -- <gradle arguments>

Examples
  npm run flutter -- build apk --profile
  npm run gradle -- app:assembleRelease --stacktrace
`);
}
