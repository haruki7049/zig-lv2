const std = @import("std");

const examples = &[_][]const u8{"amp", "fifths", "params"};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Library module
    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/lv2.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Library
    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "lv2",
        .root_module = lib_mod,
    });

    // Link lv2 library
    lib.linkLibC();
    lib.addIncludePath(b.path("lv2"));

    // Unit tests for library
    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });


    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    // Test step
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    // Example generate step
    const examples_step = b.step("examples", "Build examples");
    inline for (examples) |example| {
        const source = b.path("examples/" ++ example ++ "/" ++ example ++ ".ttl");
        const dest = example ++ ".lv2/mainfest.ttl";
        examples_step.dependOn(&b.addInstallFileWithDir(source, .prefix, dest).step);
    }
}
