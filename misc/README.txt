Hot Particles - a particle editor for LÖVE
Developed by Marcus 'ReFreezed' Thunström

Website: https://love2d.org/forums/viewtopic.php?f=5&t=88860
Code repository: https://github.com/ReFreezed/HotParticles
Examples: https://github.com/ReFreezed/HotParticlesExamples

1. Disclaimer
2. Intro
3. Controls
4. Shortcuts
5. Parameters
6. Custom shaders
7. Exporting
8. Template API



1. Disclaimer
==============================================================================

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.



2. Intro
==============================================================================

The program operates using "projects". Projects are saved in *.hotparticles
files. Each project contains one or more particle systems that are rendered
together.

Particle systems have your standard LÖVE particle system parameters, like
texture, speed and rotation. The program comes with some simple textures to
choose from, but you can also specify your own. There are some additional
parameters, like "ScaleAll" which affects multiple standard parameters, and
"kick-start steps" which fast-forwards the particle systems at start time
which is useful for continuous particle effects (like rain or fire).



3. Controls
==============================================================================

Press the particle viewing area to move the particle emitter.

Right-click on controls to show the context menu. (Or Ctrl-click in macOS.)
Middle-click tabs to close them.

Hold Ctrl/Cmd while dragging controls to snap the value.
Hold Shift to drag related controls together (like min and max speed).
Hold Alt to change the min/max limits of sliders.

Press left and right arrow keys while hovering over controls to shift the value.
Hold Ctrl or Shift to go slower or faster.

Zoom in and out with the mouse wheel.

Press parameter names to collapse or expand the section. (Note that the
parameter is still "active" while collapsed.)



4. Shortcuts
==============================================================================

(In macOS, press Cmd instead of Ctrl)

Space           Emit particles
R               Reset particles
F               Fast-forward particles (hold)
G               Slow down particles (hold)

H               Show/hide current particle system
P               Show/hide particle movement path
F1              Show/hide stats (and toggle Vsync)
F2              Show/hide panel numbers

Tab             Next particle system
Shift+Tab       Previous particle system

Ctrl+Tab        Next project
Ctrl+Shift+Tab  Previous project

Ctrl+S          Save project
Ctrl+Shift+S    Save new project
Ctrl+O          Open project
Ctrl+Shift+O    Open folder containing current project
Ctrl+E          Export project
Ctrl+Shift+E    Quick export project files

Ctrl+N          New project
Ctrl+W          Close project
Ctrl+Shift+T    Open last project

Ctrl+D          Duplicate particle system
Ctrl+Delete     Delete particle system

Ctrl+Q          Quit

Ctrl+Z          Undo
Ctrl+Shift+Z    Redo

Ctrl+PageDown   Move particle system forward
Ctrl+PageUp     Move particle system backward

Ctrl+Shift+PageDown  Move project tab right
Ctrl+Shift+PageUp    Move project tab left



5. Parameters
==============================================================================

Notes:
- Many parameter controls have additional actions available through the
    context menu.
- Paths can be absolute or relative to the saved .hotparticles file.


Project settings
------------------------------------------------------------------------------

Custom data: A custom data string attached to the project that can be used by
    an export script.

Pixelate:
- World: Enable pixel art mode. Zoom in on the particles to see the effect.
- Textures: Enable nearest neighbor filtering on textures. Linear filtering is
    used by default.

Background: Change the background of the particle viewing area.
- Pattern: Change the opacity of the checker pattern in the background.
- Size: Change the size of the pattern.
- Path: Path to a custom background image.
- Scale: Scale of the custom background image.
- Repeat x/y: Whether the custom background image should repeat.

Emitter movement: Automatically move the emitter in a pattern.
- Scale: Specify how much the emitter should move. Set one axis to 0% to use
    linear movement.
- Speed: The speed of the emitter's movement.

Region: Show a rectangular guide which can be used as a reference.

Global scale: Scale time, space and/or size parameters for all particle
    systems in the project.


Particle system parameters
------------------------------------------------------------------------------

Custom data: A custom data string attached to the particle system that can be
    used by an export script.

Texture: Choose a built-in texture preset or specify a path to an image file.
- Offset: Choose where the anchor point of the texture should be for each
    particle. The anchor point is the point the particle rotates around, among
    other things.
- Animation: Set up quads used for particle animation. You can also use a
    single quad to crop the texture if, for example, your texture contains
    graphics for many different particles.

Scale all: Scale time, space and/or size parameters in the current particle
    system.

Spawn:
- Layer: Choose where new particles should spawn relative to existing
    particles.
- Rate: How fast particles should spawn.
- Emit at start: How many particles should spawn immediately when the particle
    system starts.
- Kick-start steps: How many times the particle system should update when the
    particle system starts. (The delta time for each update is calculated
    automatically using the particles lifetime.) A higher value will look
    nicer but takes longer to execute.

Lifetime:
- Emitter: For how long the emitter should emit. Continuous emitters run
    forever.
- Particle: The lifetime of each individual particle.

Area: Distribution of the particles when they spawn.
- Offset pos: The area/emitter's offset from the base position. You can use
    this to offset multiple particle systems from each other.
- Angle: Angle of the distribution area.
- dx/dy: The size of the distribution area.
- Direction relative to area center: Enabling this will make the Direction
    parameter be relative to the distribution area's center point.

Direction: Initial movement direction of each particle.
- Spread: Maximum random deviation from the specified direction.

Speed: The initial speed of particles in the specified direction.

Acceleration:
- Linear: Acceleration in the world along the X and Y axis respectively.
- Radial: Acceleration away from, or towards, the emitter's position.
- Tangent: Acceleration perpendicular to the direction of the emitter. You can
    use this together with damping and radial acceleration to create an
    orbital effect.

Damping: Linear deceleration for each particle.

Rotation: Initial rotation of the texture (around the offset/anchor point).
- Rotation relative to direction: Enabling this will make the Rotation
    parameter be relative to the travel direction of the particle.

Spin: How fast particles should spin.

Size: The size of particles. You can specify up to 8 sizes to animate the
    size over each particle's lifetime.

Color: The color of particles. You can specify up to 8 colors to animate the
    color over each particle's lifetime. You can see a preview of the color
    over time on the right hand side.
- Blend mode: The blend mode for the particle system.

Shader: Path to a shader file to be used when rendering the particles.


Animation dialog
------------------------------------------------------------------------------

Remove all frames: Disable any existing animation.

ParticleLifetime: The lifetime of each individual particle. (This affects the
    speed of animations.)

Sequence: Tool used for quickly generating quads based on a rectangular area
    in the texture.
- Area x/y: The top left corner of the area.
- Area size: The width and height of the area.
- Padding: Amount of empty space around each quad. The space between quads
    will be double the padding.
- Spacing: Amount of empty space between quads (in addition to any padding).
- Frame size: The size of each quad, if using generation method #1.
- Rows/columns: How many quads the area should be divided in, if using
    generation method #2. (Note that the calculated width and height for each
    quad will be rounded down if they don't result in integers.)



6. Custom shaders
==============================================================================

You can specify what shaders should be used when rendering particle systems.
The program exposes some values that can be used in the shaders:

    HOT_PARTICLES
        This is defined for the preprocessor and can be used with #ifdef or in
        defined().

    hotParticlesTime
        Uniform float. Contains the current time.

    hotParticlesEmitterTime
        Uniform float. Contains the current emitter time (i.e it resets along
        with the emitter).



7. Exporting
==============================================================================

It's possible to export particle system information and textures (the original
files are copied). You can export to files or to the clipboard.

In the export dialog, any question marks ("?") in the file/folder paths will
be replaced with the name of the project file (without the file extension).

Exporting happens using Lua scripts in the "exportTemplates" folder (in macOS
see HotParticles.app/Contents/Resources). You can edit existing scripts or
make completely new ones to fit your game (see the "Template API" section).

The base folder, if specified, should usually point to the folder containing
the game's main.lua. Note that textures that are somewhere in the base folder
will not be copied.



8. Template API
==============================================================================

Templates are normal Lua scripts in the "exportTemplates" folder (in macOS see
HotParticles.app/Contents/Resources). Some of the standard Lua globals and
modules are available, but not all. Note that trying to set globals will
result in an error.

The values are available both in the 'exported' table and directly (for
example, 'exported.particleSystems' and 'particleSystems' refer to the same
value).

Functions:

    Lua( value )
        Output a value as a Lua literal. The type of the value can be nil,
        boolean, number, string or table (including nested tables). All tables
        are assumed to be arrays.

    LuaCsv( value )
        If the value is an array (or a table, rather), output all items as Lua
        literals separated by commas (Comma-Separated Values). If it's not a
        table, output the value as a Lua literal (just like the Lua()
        function).

    Text( string )
        Output the contents of a string. This function can be used to output
        anything, including binary data.

Values:

    customData
        String. Custom data for the project. Is empty by default. (Note that
        particle systems can have their own custom data too.)

    emitterPosition
        Table with these numeric fields: x, y. Is also an array. (Note that
        particle systems can specify an offset from this position with the
        'emitterOffset' field.)

    particleSystems
        Array of tables with these fields:

        blendMode               string   The blend mode for drawing.
        bufferSize              number   An appropriate buffer size.
        colors                  table    Sequence of red/green/blue/alpha values, like this: {r1,g1,b1,a1, r2,g2,b2,a2, ...}
        customData              string   Custom data for the particle system. Is empty by default.
        direction               number   The particle direction.
        emissionArea            table    Table with these fields: distribution (string), dx (number), dy (number), angle (number), relative (boolean). Is also an array.
        emissionRate            number   Particle spawning rate.
        emitAtStart             number   How many particles should emit when the particle system starts.
        emitterLifetime         number   Lifetime of the emitter. Is -1 if the emitter is continuous.
        emitterOffset           table    Position offset for the particle emitter relative to the 'emitterPosition' value. It's a table with these numeric fields: x, y. Is also an array.
        insertMode              string   Particle insert mode.
        kickStartDt             number   Delta time for when updating the emitter when the particle system starts.
        kickStartSteps          number   How many times the emitter should update when the particle system starts. May be 0.
        linearAcceleration      table    Table with these numeric fields: xmin, ymin, xmax, ymax. Is also an array.
        linearDamping           table    Table with these numeric fields: min, max. Is also an array.
        offset                  table    [Deprecated: Use 'textureOffset' instead!] Alias for the 'textureOffset' field.
        particleLifetime        table    Table with these numeric fields: min, max. Is also an array.
        quads                   table    Sequence of frames used for particle animation. Is empty if there's no animation. Each item is a table with these fields: x, y, width, height. The items are also arrays (with two additional values for texture width and height).
        radialAcceleration      table    Table with these numeric fields: min, max. Is also an array.
        relativeRotation        boolean  True if relative rotation is enabled, false otherwise
        rotation                table    Table with these numeric fields: min, max. Is also an array.
        shaderFilename          string   Filename of the shader. Is empty if no shader has been specified. This could be used as a fallback for when 'shaderPath' is empty.
        shaderPath              string   Path to the shader relative to the specified base folder. Is empty if no shader has been specified or no path is available.
        sizes                   table    Sequence of sizes.
        sizeVariation           number   How varied the sizes are. The value is between 0 and 1.
        speed                   table    Table with these numeric fields: min, max. Is also an array.
        spin                    table    Table with these numeric fields: atStart, atEnd. Is also an array.
        spinVariation           number   How varied the spinning is. The value is between 0 and 1.
        spread                  number   Angle. How spread out the particles are from their initial direction.
        tangentialAcceleration  table    Table with these numeric fields: min, max. Is also an array.
        textureHeight           number   Height of the particle texture.
        textureOffset           table    Texture offset for the particles. It's a table with these numeric fields: x, y. Is also an array.
        texturePath             string   Path to the texture relative to the specified base folder. Is empty if no path value is available.
        texturePreset           string   Name of used built-in texture if no custom texture is specified - is empty otherwise.
        textureWidth            number   Width of the particle texture.
        title                   string   Title of the particle system. Is empty by default.

    pixelateTextures
        Boolean. True if textures are set to be pixelated (i.e. use nearest-
        neighbor filtering), false otherwise (linear filtering).



==============================================================================
