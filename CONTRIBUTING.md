# Guidelines for contributing

Thanks for your interest in contributing! Before contributing, be sure to know
about these few guidelines:

- Follow the
  [GDScript style guide](https://docs.godotengine.org/en/3.2/getting_started/scripting/gdscript/gdscript_styleguide.html).
- Use [GDScript static typing](https://docs.godotengine.org/en/3.2/getting_started/scripting/gdscript/static_typing.html) whenever possible.
  - Also use type inference whenever possible (`:=`) for more concise code.
- Make sure to update the changelog for any user-facing changes, keeping the
  [changelog format](http://keepachangelog.com/en/1.0.0/) in use.
- Don't bump the version yourself. Maintainers will do this when necessary.

## Design goals

This add-on aims to:

- Provide an easy to use, yet performant LOD implementation. Like in Godot's
  core design, usability is preferred over absolute performance.
- Be easy to install and integrate into any project (no C# or GDNative required).
- Scale to hundreds of instances on mid-range hardware (ideally, thousands).
- Work with both the GLES3 and GLES2 renderers.

## Non-goals

For technical or simplicity reasons, this add-on has no plans to:

- Integrate automatic LOD generation. This would be better provided by a
  third-party add-on (preferably using GDNative for performance reasons).
- Support Godot 4.0 as that version will offer a built-in LOD system.
