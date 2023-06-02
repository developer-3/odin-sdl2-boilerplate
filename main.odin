package main

import "core:fmt"
import "core:time"

import sdl "vendor:sdl2"
import sdl_image "vendor:sdl2/image"
import sdl_ttf "vendor:sdl2/ttf"

// Some constants for sdl2
WINDOW_WIDTH  :: 800
WINDOW_HEIGHT :: 600
RENDER_FLAGS :: sdl.RENDERER_ACCELERATED

FRAMES_PER_SECOND : f64 : 60
TARGET_DELTA_TIME :: f64(1000) / FRAMES_PER_SECOND

// A simple struct to keep track of
// game/rendering specific objects/values
// that are important
Game :: struct {
	perf_frequency: f64,
    renderer: ^sdl.Renderer,
    font: ^sdl_ttf.Font,
}

game := Game{}

main :: proc()
{
    // Initing sdl2 and sdl2_image
    assert(sdl.Init(sdl.INIT_EVERYTHING) == 0, sdl.GetErrorString())
	assert(sdl_image.Init(sdl_image.INIT_PNG) != nil, sdl.GetErrorString())
	defer sdl.Quit()

	// initialize font
	init_font := sdl_ttf.Init()
	assert(init_font == 0, sdl.GetErrorString())

    // loading font example
	// game.font = sdl_ttf.OpenFont("assets/fonts/Montserrat-Regular.ttf", 200)
	// assert(game.font != nil, sdl.GetErrorString())
	defer sdl_ttf.Quit()

	// initialize window
	window := sdl.CreateWindow("Window Name", sdl.WINDOWPOS_UNDEFINED, sdl.WINDOWPOS_UNDEFINED, WINDOW_WIDTH, WINDOW_HEIGHT, sdl.WINDOW_SHOWN)
	if window == nil {
		fmt.eprintln("Failed to create window")
		return
	}
	defer sdl.DestroyWindow(window)

    // initialize renderer
    game.renderer = sdl.CreateRenderer(window, -1, RENDER_FLAGS)
    assert(game.renderer != nil, sdl.GetErrorString())
    defer sdl.DestroyRenderer(game.renderer)

    // define tick and variables for keeping track of time
	start_tick := time.tick_now()
    start : f64
	end : f64
	game.perf_frequency = f64(sdl.GetPerformanceFrequency())

    // start the game loop
    loop: for {
        start = get_time()
		duration := time.tick_since(start_tick)
		t := f32(time.duration_seconds(duration))

        // event polling
		event: sdl.Event
		for sdl.PollEvent(&event) {
			// #partial switch tells the compiler not to error if every case is not present
			#partial switch event.type {
			case .KEYDOWN:
				#partial switch event.key.keysym.sym {
				case .ESCAPE:
					// labelled control flow
					break loop
				}
			case .QUIT:
				// labelled control flow
				break loop
			}
		}

        // rendering goes here
        // ex... render_everything()

        end = get_time()
		for end - start < TARGET_DELTA_TIME
		{
			end = get_time()
		}
    }
}

get_time :: proc() -> f64
{
	return f64(sdl.GetPerformanceCounter()) * 1000 / game.perf_frequency
}
