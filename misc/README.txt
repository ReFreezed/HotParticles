Hot Particles - a particle editor for LÖVE
Developed by Marcus 'ReFreezed' Thunström

1. Disclaimer
2. Info and controls
3. Shortcuts
4. Exporting
5. Template API


1. Disclaimer
------------------------------------------------------------------------------

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


2. Info and controls
------------------------------------------------------------------------------

The program operates using "projects". Projects are saved in *.hotparticles
files. Each project contains one or more particle systems that are rendered
together.

Particle systems have your standard LÖVE particle system parameters, like
texture, speed and rotation. The program comes with some simple textures to
choose from, but you can also specify your own. There are some additional
parameters, like "ScaleAll" which affects multiple standard parameters, and
"kick-start steps" which fast-forwards the particle systems at start time
which is useful for continuous particle effects (like rain or fire).

Press the particle viewing area to move the particle emitter.

Right-click on controls to show the context menu. (Or Ctrl-click in macOS.)
Middle-click tabs to close them.

Hold Ctrl/Cmd while dragging controls to snap the value.
Hold Shift to drag related controls together (like min and max speed).
Hold Alt to change the min/max limits of sliders.

Press left and right arrow keys while hovering over controls to shift the
value. Hold Ctrl or Shift to go slower or faster.


3. Shortcuts
------------------------------------------------------------------------------

(In macOS, press Cmd instead of Ctrl)

Space           Emit particles
R               Reset particles
F               Fast-forward particles (hold)
G               Slow down particles (hold)

H               Show/hide current particle system
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

Ctrl+N          New project
Ctrl+W          Close project
Ctrl+Shift+T    Open last project

Ctrl+D          Duplicate particle system
Ctrl+Delete     Delete particle system

Ctrl+Q          Quit

Ctrl+Z          Undo
Ctrl+Shift+Z    Redo


4. Exporting
------------------------------------------------------------------------------

It's possible to export particle system information and textures (the original
files are copied). You can export to files or to the clipboard.

In the export dialog, any question marks ("?") in the file/folder paths will
be replaced with the name of the project file (without the file extension).

Exporting happens using Lua scripts in the "exportTemplates" folder. You can
edit existing scripts or make completely new ones to fit your game (see the
"Template API" section).


5. Template API
------------------------------------------------------------------------------

Templates are normal Lua scripts in the "exportTemplates" folder. Some of the
standard Lua globals and modules are available, but not all. Note that trying
to set globals will result in an error.

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
        Output a raw string. This function can be used to output anything,
        including binary data.

Values:

    particleSystems
        Array of tables with these fields:

        blendMode               string   The blend mode for drawing.
        bufferSize              number   An appropriate buffer size.
        colors                  table    Sequence of red/green/blue/alpha values, like this: {r1,g1,b1,a1, r2,g2,b2,a2, ...}
        direction               number   The particle direction.
        emissionArea            table    Table with these fields: distribution (string), dx (number), dy (number), angle (number), relative (boolean). Is also an array.
        emissionRate            number   Particle spawning rate.
        emitAtStart             number   How many particles should emit when the particle system starts.
        emitterLifetime         number   Lifetime of the emitter. Is -1 if the emitter is continuous.
        insertMode              string   Particle insert mode.
        kickStartDt             number   Delta time for when updating the emitter when the particle system starts.
        kickStartSteps          number   How many times the emitter should update when the particle system starts. May be 0.
        linearAcceleration      table    Table with these numeric fields: xmin, ymin, xmax, ymax. Is also an array.
        linearDamping           table    Table with these numeric fields: min, max. Is also an array.
        offset                  table    Texture offset for the particles. It's a table with these numeric fields: x, y. Is also an array.
        particleLifetime        table    Table with these numeric fields: min, max. Is also an array.
        quads                   table    Sequence of frames used for particle animation. Is empty if there's no animation. Each item is a table with these fields: x, y, width, height. The items are also arrays with additional values for texture width and height.
        radialAcceleration      table    Table with these numeric fields: min, max. Is also an array.
        relativeRotation        boolean  True if relative rotation is enabled, false otherwise
        rotation                table    Table with these numeric fields: min, max. Is also an array.
        sizes                   table    Sequence of sizes.
        sizeVariation           number   How varied the sizes are. The value is between 0 and 1.
        speed                   table    Table with these numeric fields: min, max. Is also an array.
        spin                    table    Table with these numeric fields: atStart, atEnd. Is also an array.
        spinVariation           number   How varied the spinning is. The value is between 0 and 1.
        spread                  number   Angle. How spread out the particles are from their initial direction.
        tangentialAcceleration  table    Table with these numeric fields: min, max. Is also an array.
        textureHeight           number   Height of the particle texture.
        texturePath             string   Path to the texture relative to the specified base folder. Is empty if no path value is available.
        texturePreset           string   Fallback for when texturePath is empty.
        textureWidth            number   Width of the particle texture.
        title                   string   Title of the particle system. Is empty by default.

    pixelateTextures
        Boolean. True if textures are set to be pixelated (i.e. use nearest
        neighbor filtering), false otherwise (linear filtering).

