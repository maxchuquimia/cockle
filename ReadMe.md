<img src="https://cdn.leonardo.ai/users/4125042f-37fc-4781-8375-41a380bab6a0/generations/f41590c1-85c7-4e55-b101-2d83bef36f7d/variations/Default_Cockle_seas_shell_2d_digital_art_app_icon_style_0_f41590c1-85c7-4e55-b101-2d83bef36f7d_0.png" width="150" title="a cockle shell">

# Cockle 

Run any shell commands as if they were a prebuilt Swift function using the magic of `@dynamicCallable` and `@dynamicMemberLookup`.
Simply use underscores instead of dashes!

_The cool names [ShellSwift](https://github.com/kareman/SwiftShell), [Shift](https://github.com/wickwirew/Shift), [Swell](https://github.com/willtyler98/swell), [Swsh](https://github.com/cobbal/swsh), [Swish](https://github.com/rogerluan/Swish), [ShellKit](https://github.com/BinaryBirds/shell-kit) and [SwiftyShell](https://github.com/AlTavares/SwiftyShell) were already taken 😭_ 

## Examples

### Cloning a Git repo
```swift
let shell = try Shell()

try shell.git(
    clone: (),
    __depth: 5,
    __branch: "develop",
    "https://github.com/org/cool-repo.git "
)

try shell.cd("cool-repo")

let history = try shell.git(log: (), __oneline: ())
```

### Archiving using Xcodebuild
```swift
let shell = try Shell()

try shell.xcodebuild(
    archive: (),
    _project: "CoolApp.xcodeproj",
    _scheme: "CoolApp-Prod",
    _archivePath: "/tmp/output.xcarchive"
)
```

### Creating some files
```swift
let shell = try Shell()

try shell.mkdir(_p: "cockle/example")

for ext in [".txt", ".swift", ".md"] {
    try shell.touch("cockle/example/Hello" + ext)
}

let allFiles = try shell.ls(_l: (), _a: ())
print(allFiles.lines)
```
