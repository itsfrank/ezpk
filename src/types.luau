export type GitDep = {
    [number]: string,
    rev: string?,
    branch: string?,
}

export type PathDep = {
    [number]: string,
    copy: boolean?,
}

export type Dependency = {
    git: GitDep?,
    path: PathDep?,
}

export type Config = {
    deps: { [string]: Dependency },
    actions: {
        post_switch: ((config: Config, manifest: Manifest) -> ())?,
    }?,
}

export type DepManifest = {
    root_dir: string,
}

export type Manifest = {
    deps: { [string]: DepManifest },
}

return {}
