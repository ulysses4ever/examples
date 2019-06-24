"""Execute a binary.

The example below executes the binary target "//actions_run:merge" with
some arguments. The binary will be automatically built by Bazel.

The rule must declare its dependencies. To do that, we pass the target to
the attribute "_merge_tool". Since it starts with an underscore, it is private
and users cannot redefine it.
"""

def _impl(ctx):
    # Flagfile is used to pass parameteres for one worker request
    flagfile = ctx.actions.declare_file("flagfile.txt")
    ctx.actions.write(flagfile, content = "test")

    # The list of arguments we pass to the script.
    args = [ctx.outputs.out.path] + [f.path for f in ctx.files.chunks] + ["@" + flagfile.path]

    cmd = ctx.executable._merge_tool.path + " {args}".format(
        args = " ".join(args[:-1])
    )
    
    # Action to call the script.
    ctx.actions.run_shell(
        inputs = ctx.files.chunks + [ctx.executable._merge_tool, flagfile],
        outputs = [ctx.outputs.out],
        arguments = [args[-1]],
        progress_message = "Merging into %s" % ctx.outputs.out.short_path,
        command=cmd,
        mnemonic="mymerge",
	execution_requirements = { "supports-workers": "1" },
    )

concat = rule(
    implementation = _impl,
    attrs = {
        "chunks": attr.label_list(allow_files = True),
        "out": attr.output(mandatory = True),
        "_merge_tool": attr.label(
            executable = True,
            cfg = "host",
            allow_files = True,
            default = Label("//actions_run_shell_worker:merge"),
        ),
    },
)
