local m_fs = {}

--- removes the thing at path, regardless if its a file or dir
function m_fs.rm(path: string)
    local lune_fs = require("@lune/fs")

    if lune_fs.isFile(path) then
        lune_fs.removeFile(path)
    else
        lune_fs.removeDir(path)
    end
end

return m_fs
