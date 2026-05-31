pub const ZagError = error{
    CurrentDirectoryNotWritable,
    ZigNotFound,
    ZigVersionFailed,
    ZigVersionEmpty,
    TemplatesDirectoryMissing,
    BasicTemplateMissing,
    BasicBuildFileMissing,
    BasicMainFileMissing,
    InvalidProjectName,
    ProjectAlreadyExists,
    ExecutableDirectoryMissing,
};
