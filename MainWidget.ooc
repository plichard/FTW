use sdl,glew,glu
import sdl/[Sdl, Video, Event]
import glew
import glu/Glu
import Types

getchar: extern func

MainWidget: class {
	width, height, bpp, videoFlags : Int
	fullscreen := false
	isActive := false
	title := "IDE v2"
	surface: Surface*
	
	quit: func(errcode: Int) -> Int {
		SDL quit()
		return errcode
	}
	
	resizeWindow: func( =width, =height ) -> Bool {	
		ratio: GLfloat

		if ( height == 0 )
			height = 1
			
		ratio = width as GLfloat / height as GLfloat
		glViewport( 0, 0,width as GLint, height as GLint)

		glMatrixMode( GL_PROJECTION )
		glLoadIdentity( )

		gluOrtho2D(0,width,height,0);

		glMatrixMode( GL_MODELVIEW )

		glLoadIdentity( )
		
		glEnable(GL_BLEND)
		glDisable(GL_DEPTH_TEST)
		//glBlendFunc(GL_SRC_ALPHA,GL_ONE)
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

		return true
	}
	
	
	handleEvent: func( event: Event* ) -> Bool {
		match( event@ type ) {
			case SDL_ACTIVEEVENT => {
			    if ( event@ active gain == 0 )
					isActive = false
			    else
					isActive = true
			}
			   
			case SDL_VIDEORESIZE => {
			    /* handle resize event */
			    surface = SDLVideo setMode( event@ resize w,event@ resize h, 32, videoFlags )
			    if ( !surface )
				{
				    fprintf( stderr, "Could not get a surface after resize: %s\n", SDL getError( ) )
				    quit(1)
				}
			    resizeWindow( event@ resize w, event@ resize h )
			    return true
			}
			 
			case SDL_KEYDOWN => return handleKeyPress( event@ key keysym&)
			   
			case SDL_QUIT => return false
		}
		return false
	}
		
	handleKeyPress: func(keysym: Keysym*) -> Bool{
		match (keysym@ sym ) {
			case SDLK_F11 =>
				/* F1 key was pressed
				 * this toggles fullscreen mode
				 */
				SDL WM_ToggleFullScreen( surface )
				return true
			}
		return false
	}
	
	
	/* general OpenGL initialization function */
	initGL: func -> Bool {

		glShadeModel( GL_SMOOTH )

		glClearColor( 0.0, 0.0, 0.0, 0.0 )

		glClearDepth( 1.0 )

		glDisable( GL_DEPTH_TEST )
		return true
	}
	
	init: func(=width,=height,=bpp,=fullscreen) {
	
		videoInfo: VideoInfo*

		/* initialize SDL */
		if ( SDL init( SDL_INIT_EVERYTHING ) < 0 )
		{
			fprintf( stderr, "SDL initialization failed: %s\n", SDL getError( ) )
			quit( 1 )
		}

		/* Fetch the video info */
		videoInfo = SDL getVideoInfo( )

		if ( !videoInfo )
		{
			fprintf( stderr, "Video query failed: %s\n", SDL getError( ) )
			quit( 1 );
		}

		/* the flags to pass to SDL_SetVideoMode */
		videoFlags  = SDL_OPENGL          /* Enable OpenGL in SDL */
		videoFlags |= SDL_GL_DOUBLEBUFFER /* Enable double buffering */
		videoFlags |= SDL_HWPALETTE       /* Store the palette in hardware */
		videoFlags |= SDL_RESIZABLE       /* Enable window resizing */
		
		if(fullscreen) {
			videoFlags |= SDL_FULLSCREEN
		}

		/* This checks to see if surfaces can be stored in memory */
		if ( videoInfo@ hw_available )
			videoFlags |= SDL_HWSURFACE
		else
			videoFlags |= SDL_SWSURFACE

		/* This checks if hardware blits can be done */
		if ( videoInfo@ blit_hw )
			videoFlags |= SDL_HWACCEL

		/* Sets up OpenGL double buffering */
		SDL GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 )

		/* get a SDL surface */
		surface = SDLVideo setMode( width, height, bpp,videoFlags )

		/* Verify there is a surface */
		if ( !surface )
		{
			fprintf( stderr,  "Video mode set failed: %s\n", SDL getError( ) )
			quit( 1 )
		}

		/* initialize OpenGL */
		if ( initGL( ) == false )
		{
			fprintf( stderr, "Could not initialize OpenGL.\n" )
			quit( 1 )
		}

		/* Resize the initial window */
		resizeWindow( width, height )
		
		SDL enableKeyRepeat(300,30)
		//glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE)
		//glEnable(GL_COLOR_MATERIAL)

	}
	
	
	title: func(=title) {
		SDLVideo wmSetCaption(title, null)
	}
}
