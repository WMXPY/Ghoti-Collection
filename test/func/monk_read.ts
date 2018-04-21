import * as fs from 'fs';

export default function (fun: Function): string {
    const fsTemp = fs.readFileSync;
    const fsExistTemp = fs.existsSync;
    let fileContent: string = '';

    (fs.existsSync as any) = () => { return true };
    (fs.readFileSync as any) = function (fileName: string, code: string) {
        fileContent += `${fileName} with ${code}`;
        fileContent += '\ntest file content';
        fileContent += '\ntest replaceable ${|replace|}';
        fileContent += '\n';
    };
    try {
        fun();
    } catch (err) {
        console.log(err);
    }
    (fs.readFileSync as any) = fsTemp;
    (fs.existsSync as any) = fsExistTemp;
    return fileContent;
}
