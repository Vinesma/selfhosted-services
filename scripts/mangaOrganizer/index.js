const { argv, exit } = require("process");
const { execSync } = require("child_process");
const fs = require("fs");

// TODO: use this for file paths
const path = require("path");

const dir = argv?.[2];
const chapterRegex = /c(\d\d\d)/;
const volumeRegex = /v(\d\d)/;

if (!dir) {
    console.log("No directory specified, exiting...");
    exit(1);
}

const files = fs.readdirSync(dir).filter(item => item.endsWith(".cbz"));

// Unpack archives
files.forEach(file => {
    const fileNoExtension = file.replace(".cbz", "");

    execSync(`unzip "${dir}/${file}" -d "${dir}/${fileNoExtension}"`);

    // Remove archives that have been unpacked
    fs.unlinkSync(`${dir}/${file}`);
});

// Get the unpacked folders
const folders = fs
    .readdirSync(dir)
    .filter(item => fs.statSync(`${dir}/${item}`).isDirectory());

// Create chapter folders inside of volume folders
folders.forEach(folder => {
    const pages = fs.readdirSync(`${dir}/${folder}`);
    const chapterFolders = {};

    pages.forEach(page => {
        const chapter = page.match(chapterRegex)[1];

        if (chapterFolders[chapter]) {
            chapterFolders[chapter] = [...chapterFolders[chapter], page];
        } else {
            chapterFolders[chapter] = [page];
        }
    });

    Object.keys(chapterFolders).forEach(chapter => {
        const volume = folder.match(volumeRegex)[1];
        const chapterFolder = `Vol${volume} Ch${chapter}`;
        const chapterPages = chapterFolders[chapter];

        fs.mkdirSync(`${dir}/${folder}/${chapterFolder}`);

        // move pages into chapter folder
        chapterPages.forEach(item => {
            fs.renameSync(
                `${dir}/${folder}/${item}`,
                `${dir}/${folder}/${chapterFolder}/${item}`
            );
        });

        // move chapter folder up a level
        fs.renameSync(
            `${dir}/${folder}/${chapterFolder}`,
            `${dir}/${chapterFolder}`
        );
    });

    // delete empty original volume folder
    fs.rmdirSync(`${dir}/${folder}`);
});

// zip chapters into .cbz
const chapterFolders = fs
    .readdirSync(dir)
    .filter(item => fs.statSync(`${dir}/${item}`).isDirectory());

chapterFolders.forEach(item => {
    execSync(`zip -rj "${dir}/${item}.cbz" "${dir}/${item}"`);

    // Remove folders that have been packed
    fs.rmSync(`${dir}/${item}`, { recursive: true });
});
