const fs = require('fs');
const path = require('path');

function processFile(filePath) {
    let content = fs.readFileSync(filePath, 'utf8');
    let original = content;

    // 1. const x = require('y') -> import x from 'y'
    content = content.replace(/(?:const|let|var)\s+([a-zA-Z0-9_]+)\s*=\s*require\(['"]([^'"]+)['"]\);?/g, "import $1 from '$2';");

    // 2. const { x, y } = require('y') -> import { x, y } from 'y'
    content = content.replace(/(?:const|let|var)\s+\{([^}]+)\}\s*=\s*require\(['"]([^'"]+)['"]\);?/g, "import { $1 } from '$2';");

    // 3. require('y') (no assignment) -> import '$2'
    content = content.replace(/require\(['"]([^'"]+)['"]\);?/g, "import '$1';");

    // 4. module.exports = x -> export default x
    content = content.replace(/module\.exports\s*=\s*(?!\{)/g, 'export default ');

    // 5. module.exports = { x, y } -> export { x, y } or export default { x, y }
    // Let's use export default { x, y } for simpler compatibility for now
    // Actually regex 4 covers this too: module.exports = { ... } becomes export default { ... }

    // 6. exports.x = y -> export const x = y (only if not inside a block)
    // To be safe, let's keep exports.x = y alone, we can manually check or convert exports.x to export {x } later.

    // 7. Add .js extension to relative imports
    content = content.replace(/import\s+([^'"]*)\s*from\s*['"](\.[^'"]+)['"]/g, (match, p1, p2) => {
        if (!p2.endsWith('.js') && !p2.endsWith('.json')) {
            // Check if it's a directory (index.js implied)
            try {
                const dirPath = path.resolve(path.dirname(filePath), p2);
                if (fs.existsSync(dirPath) && fs.statSync(dirPath).isDirectory()) {
                    return `import ${p1} from '${p2}/index.js'`;
                }
            } catch (e) {}
            return `import ${p1} from '${p2}.js'`;
        }
        return match;
    });

    // Handle just import './file'
    content = content.replace(/import\s+['"](\.[^'"]+)['"]/g, (match, p1) => {
        if (!p1.endsWith('.js') && !p1.endsWith('.json')) {
            try {
                const dirPath = path.resolve(path.dirname(filePath), p1);
                if (fs.existsSync(dirPath) && fs.statSync(dirPath).isDirectory()) {
                    return `import '${p1}/index.js'`;
                }
            } catch (e) {}
            return `import '${p1}.js'`;
        }
        return match;
    });

    if (content !== original) {
        fs.writeFileSync(filePath, content, 'utf8');
        console.log(`Updated ${filePath}`);
    }
}

function traverse(dir) {
    const items = fs.readdirSync(dir);
    for (const item of items) {
        if (item === 'node_modules' || item === '.git') continue;
        const fullPath = path.join(dir, item);
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory()) {
            traverse(fullPath);
        } else if (stat.isFile() && fullPath.endsWith('.js') && item !== 'convert-to-esm.js') {
            processFile(fullPath);
        }
    }
}

traverse(path.resolve(__dirname));
