#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifndef aTHX_
#define aTHX_
#endif

#include <SDL.h>

MODULE = SDL::Surface 	PACKAGE = SDL::Surface    PREFIX = surface_

=for documentation

SDL_Surface -- Graphic surface structure 

  typedef struct SDL_Surface {
      Uint32 flags;                           /* Read-only */
      SDL_PixelFormat *format;                /* Read-only */
      int w, h;                               /* Read-only */
      Uint16 pitch;                           /* Read-only */
      void *pixels;                           /* Read-write */
      SDL_Rect clip_rect;                     /* Read-only */
      int refcount;                           /* Read-mostly */

    /* This structure also contains private fields not shown here */
  } SDL_Surface;

=cut

SDL_Surface *
surface_new (CLASS, flags, width, height, depth, Rmask, Gmask, Bmask, Amask )
	char* CLASS
	Uint32 flags
	int width
	int height
	int depth
	Uint32 Rmask
	Uint32 Gmask
	Uint32 Bmask
	Uint32 Amask
	CODE:
		RETVAL = SDL_CreateRGBSurface ( flags, width, height,
				depth, Rmask, Gmask, Bmask, Amask );
	OUTPUT:
		RETVAL


SDL_Surface *
surface_load (CLASS, filename )
	char* CLASS
	char* filename
	CODE:
		RETVAL = IMG_Load(filename);
	OUTPUT:
		RETVAL

int
surface_blit ( src, src_rect, dest, dest_rect )
	SDL_Surface *src
	SDL_Surface *dest
	SDL_Rect *src_rect
	SDL_Rect *dest_rect
	CODE:
		RETVAL = SDL_BlitSurface(src,src_rect,dest,dest_rect);
	OUTPUT:
		RETVAL

int
surface_fill_rect ( dest, dest_rect, color )
	SDL_Surface *dest
	SDL_Color *color
	SDL_Rect *dest_rect
	CODE:
		Uint32 pixel = SDL_MapRGB(dest->format,color->r,color->g,color->b);
		RETVAL = SDL_FillRect(dest,dest_rect,pixel);
	OUTPUT:
		RETVAL
		
void
surface_update_rect ( surface, x, y, w ,h )
	SDL_Surface *surface
	int x
	int y
	int w
	int h
	CODE:
		SDL_UpdateRect(surface,x,y,w,h);

void
surface_update_rects ( surface, ... )
	SDL_Surface *surface
	CODE:
		SDL_Rect *rects, *temp;
		int num_rects,i;
		if ( items < 2 ) return;
		num_rects = items - 1;
			
		rects = (SDL_Rect *)safemalloc(sizeof(SDL_Rect)*items);
		for(i=0;i<num_rects;i++) {
			temp = (SDL_Rect *)SvIV(ST(i+1));
			rects[i].x = temp->x;
			rects[i].y = temp->y;
			rects[i].w = temp->w;
			rects[i].h = temp->h;
		} 
		SDL_UpdateRects(surface,num_rects,rects);
		safefree(rects);

SDL_Surface *
surface_display ( surface )
	SDL_Surface *surface
	CODE:
		char* CLASS = 'SDL::Surface\0';
		RETVAL = SDL_DisplayFormat(surface);
	OUTPUT:
		RETVAL

Uint16
surface_w ( surface )
	SDL_Surface *surface
	CODE:
		RETVAL = surface->w;
	OUTPUT:
		RETVAL

Uint16
surface_h ( surface )
	SDL_Surface *surface
	CODE:
		RETVAL = surface->h;
	OUTPUT:
		RETVAL

void
surface_DESTROY(surface)
	SDL_Surface *surface
	CODE:
		Uint8* pixels = surface->pixels;
		Uint32 flags = surface->flags;
		SDL_FreeSurface(surface);
		if (flags & SDL_PREALLOC)
			Safefree(pixels);