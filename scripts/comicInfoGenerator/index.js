const fs = require("fs");

const getDirectoryJsonFiles = () => {
    const filePaths = fs.readdirSync(".");
    const jsonFilePaths = filePaths.filter(
        path => path.endsWith(".json") && path !== "package.json"
    );

    return jsonFilePaths;
};

const parseJSONFile = filePath => {
    const rawFile = fs.readFileSync(filePath, { encoding: "utf8" });
    const parsedFile = JSON.parse(rawFile);

    return parsedFile;
};

const jsonFilePaths = getDirectoryJsonFiles();

if (jsonFilePaths.length === 0) {
    console.error("No metadata files found.");
    process.exit(1);
}

const metadataFilePath = jsonFilePaths[0];
const metadata = parseJSONFile(metadataFilePath);

const xmlTags = [
    { name: "Title", mapTo: "title", default: null },
    { name: "Tags", mapTo: "tags", default: "" },
    { name: "AgeRating", mapTo: null, default: "18" },
    { name: "LanguageISO", mapTo: "lang", default: "en-us" },
];

const xmlHead = [
    `<?xml version="1.0"?>\n`,
    `<ComicInfo xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">\n`,
];
const xmlEnd = [`</ComicInfo>`];

const xmlBody = xmlTags.map(tag => {
    let metadataValue = tag.default ?? "";

    if (tag.mapTo) {
        const key = tag.mapTo;

        if (tag.name === "Tags") {
            metadataValue = metadata[key]
                .filter(value => {
                    if (value.startsWith("male:")) return false;

                    return true;
                })
                .map(value => {
                    if (value.includes(":") && !value.startsWith("artist:")) {
                        return value.split(":")[1];
                    }

                    return value;
                });

            if (metadata.category === "nhentai") {
                metadataValue = metadataValue.concat(
                    `artist:${metadata.artist[0]}`
                );
            }
        } else {
            metadataValue = metadata[key];
        }
    }

    return `    <${tag.name}>${metadataValue}</${tag.name}>\n`;
});

const xmlContent = [...xmlHead, ...xmlBody, ...xmlEnd].reduce(
    (acc, value) => `${acc}${value}`
);

fs.writeFileSync("ComicInfo.xml", xmlContent, { encoding: "utf-8" });
