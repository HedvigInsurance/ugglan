const translations = require(__dirname +
  "/../Src/Assets/Localization/Localization.json");

let indent = (string, numberOfIndents) =>
  [...Array(numberOfIndents)].map(() => ` `).join("") + string;

let isLast = (index, array) => index + 1 === array.length;

const placeholderRegex = new RegExp("({[a-zA-Z0-9]+})", "g");
const placeholderKeyRegex = new RegExp("([a-zA-Z0-9]+)", "g");

const concat = (x, y) => x.concat(y);

const flatMap = (f, xs) => xs.map(f).reduce(concat, []);

const findReplacements = text =>
  text
    .split(placeholderRegex)
    .filter(value => value)
    .filter(value => value[0] == "{" && value[value.length - 1] == "}");

const getReplacementArgumentNames = matches =>
  matches.map(match => {
    const key = match.match(placeholderKeyRegex)[0];
    return key;
  });

let generateSwitchCase = language => {
  const cases = language.translations
    .map(translation => {
      const matches = findReplacements(translation.text);

      if (matches.length) {
        let argumentNames = getReplacementArgumentNames(matches);

        const translationsRepoClosingBracket = indent("}", 14);
        const translationsRepo = indent(
          `if let text = TranslationsRepo.findWithReplacements(key, replacements: [${argumentNames.map(
            name => `"${name}": ${name}`
          )}]) {\n${indent(
            "return text",
            16
          )}\n${translationsRepoClosingBracket}\n`,
          14
        );

        let text = translation.text;

        matches.forEach(
          (match, i) => (text = text.replace(match, `\\(${argumentNames[i]})`))
        );

        const returnStatement =
          indent("\n", 12) +
          indent(`return """\n${indent(text, 14)}\n${indent('"""', 14)}`, 14);

        return `case let .${translation.key.value}(${argumentNames.map(
          name => `${name}`
        )}):\n${indent(translationsRepo, 12)}${returnStatement}`;
      }

      const translationsRepoClosingBracket = indent("}", 14);
      const translationsRepo = indent(
        `if let text = TranslationsRepo.find(key) {\n${indent(
          "return text",
          16
        )}\n${translationsRepoClosingBracket}\n`,
        14
      );

      const returnStatement =
        indent("\n", 12) +
        indent(
          `return """\n${indent(translation.text, 14)}\n${indent('"""', 14)}`,
          14
        );

      const result = `case .${
        translation.key.value
      }:\n${translationsRepo}${returnStatement}`;

      return result;
    })
    .map(string => {
      return indent(string + "\n", 12);
    });

  cases.push(indent("default: return String(describing: key)", 12));

  const switchCase = indent(
    `switch key {\n${cases.join("")}\n${indent("}", 10)}`,
    10
  );

  return switchCase;
};

let output = `// Generated automagically, don't edit yourself

import Foundation

// swiftlint:disable identifier_name type_body_length type_name line_length nesting file_length

public struct Localization {
    enum Language {
    ${translations.data.languages
      .map((language, i) => {
        let result = indent(`case ${language.code}`, 6);

        if (!isLast(i, translations.data.languages)) {
          return result + "\n";
        }

        return result;
      })
      .join("")}
    }

    enum Key {
    ${translations.data.keys
      .map((key, i) => {
        let description = key.description
          ? indent(`/// ${key.description}`, 6) + "\n"
          : "";

        const replacementArguments = flatMap(
          a => a,
          flatMap(
            language =>
              language.translations.filter(
                translation => translation.key.value === key.value
              ),
            translations.data.languages
          ).map(translation => findReplacements(translation.text))
        );

        if (replacementArguments.length) {
          const argumentNames = getReplacementArgumentNames(
            replacementArguments
          );

          let result =
            description +
            indent(
              `case ${key.value}(${argumentNames.map(
                name => `${name}: String`
              )})`,
              6
            );

          if (!isLast(i, translations.data.keys)) {
            return result + "\n";
          }

          return result;
        }

        let result = description + indent(`case ${key.value}`, 6);

        if (!isLast(i, translations.data.keys)) {
          return result + "\n";
        }

        return result;
      })
      .join("")}
    }

    struct Translations {
    ${translations.data.languages
      .map((language, i) => {
        let forFunc = indent(
          `static func \`for\`(key: Localization.Key) -> String {\n${generateSwitchCase(
            language
          )}\n${indent("}", 8)}`,
          8
        );
        let result = indent(
          `struct ${language.code} {\n${forFunc}\n${indent("}", 6)}`,
          6
        );

        if (!isLast(i, translations.data.languages)) {
          return result + "\n\n";
        }

        return result;
      })
      .join("")}
    }
}
`;

const swiftFileLocation =
  __dirname + "/../Src/Assets/Localization/Localization.swift";

const fs = require("fs");
fs.writeFile(swiftFileLocation, output, function(err) {
  if (err) {
    return console.log(err);
  }

  console.log("Generated Swift translations file!");
});

const { exec } = require("child_process");
exec(
  __dirname +
    `/../Pods/SwiftFormat/CommandLineTool/swiftformat ${swiftFileLocation}`
);
