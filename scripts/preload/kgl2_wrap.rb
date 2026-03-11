# kgl2_wrap.rb
# Author: white-axe (2026)

# Creative Commons CC0: To the extent possible under law, white-axe has
# dedicated all copyright and related and neighboring rights to this script
# to the public domain worldwide.
# https://creativecommons.org/publicdomain/zero/1.0/

require_relative 'win32_wrap' unless Win32API.method_defined? :mkxp_native_call
require 'objspace'

module KGL2_Impl
	@initialized = false
	@light_blending = false
	@soft_shadows = false
	@framebuffer = nil
	@shadowbuffer = nil

	class KglVersion
		def call
			200
		end
	end

	# If the library is already initialized, return 102.
	# If the library is not initialized, initialize it and return 1.
	class KglLoad
		def call
			return 102 if @initialized
			@initialized = true
			1
		end
	end

	# Set the red, green, blue and alpha components of each pixel in the bitmap to zero, then return 1.
	class KglBlank
		def call(bitmap_id)
			bitmap = ObjectSpace._id2ref(bitmap_id)
			bitmap.clear
			1
		end
	end

	# Set each pixel in the bitmap to the given color, then return 1.
	# The color is a 32-bit integer, where
	# the least significant 8 bits are the blue component,
	# the second-least significant 8 bits are the green component,
	# the second-most significant 8 bits are the red component, and
	# the most significant 8 bits are the alpha component.
	class KglClear
		def call(bitmap_id, color_packed)
			bitmap = ObjectSpace._id2ref(bitmap_id)
			color = Color.new((color_packed >> 16) & 0xff, (color_packed >> 8) & 0xff, color_packed & 0xff, (color_packed >> 24) & 0xff)
			bitmap.fill_rect(bitmap.rect, color)
			1
		end
	end

	# Invert the values of the red, green and blue components of each pixel in the bitmap, then return 1.
	class KglInvert
		def call(bitmap_id)
			bitmap = ObjectSpace._id2ref(bitmap_id)
			bitmap._kgl_invert
			1
		end
	end

	# If the two bitmaps do not have the same width and height, return 112.
	# If the two bitmaps have the same width and height, copy the contents of the second bitmap to the first bitmap, then return 1.
	class KglClone
		def call(dst_bitmap_id, src_bitmap_id)
			dst_bitmap = ObjectSpace._id2ref(dst_bitmap_id)
			src_bitmap = ObjectSpace._id2ref(src_bitmap_id)
			rect = dst_bitmap.rect
			return 112 if rect != src_bitmap.rect
			dst_bitmap.blt(0, 0, src_bitmap, rect)
			1
		end
	end

	# If the library is not initialized, return 101.
	# If the library is initialized, record the bitmap as the KGL framebuffer, then return 1.
	class KglBindFramebuffer
		def call(bitmap_id)
			return 101 unless @initialized
			bitmap = ObjectSpace._id2ref(bitmap_id)
			@framebuffer = bitmap
			1
		end
	end

	# If the library is not initialized, return 101.
	# If the library is initialized, record the bitmap as the KGL shadowbuffer, then return 1.
	class KglBindShadowbuffer
		def call(bitmap_id)
			return 101 unless @initialized
			bitmap = ObjectSpace._id2ref(bitmap_id)
			@shadowbuffer = bitmap
			1
		end
	end

	# Record the KGL framebuffer as unbound, then return 1.
	class KglUnbindFramebuffer
		def call
			@framebuffer = nil
			1
		end
	end

	# Record the KGL shadowbuffer as unbound, then return 1.
	class KglUnbindShadowbuffer
		def call
			@shadowbuffer = nil
			1
		end
	end

	# If the KGL framebuffer is unbound, return 103.
	# If the KGL framebuffer is bound, set the red, green, blue and alpha components of each pixel in the KGL framebuffer to zero, then return 1.
	class KglClearFramebuffer
		def call
			return 103 if @framebuffer.nil?
			@framebuffer.clear
			1
		end
	end

	# Multiply the red, green and blue components of each pixel of the bitmap by its alpha component divided by 255,
	# then set the alpha component of each pixel to 0, then return 1.
	class KglCompressAlpha
		def call(bitmap_id)
			bitmap = ObjectSpace._id2ref(bitmap_id)
			bitmap._kgl_compress_alpha
			1
		end
	end

	# If the argument is nonzero, enable light blending, then return 1.
	# If the argument is zero, disable light blending, then return 1.
	class KglLightBlending
		def call(enabled_integer)
			enabled = enabled_integer && enabled_integer != 0 ? true : false
			@light_blending = enabled
			1
		end
	end

	# If the KGL framebuffer is unbound, return 103.
	# Otherwise, perform a pixel-by-pixel subtraction of a region of the bitmap from the KGL framebuffer,
	# and return 1 if the operation succeeded or 111 if it failed due to out-of-bounds x and y values.
	class KglLightShader
		def call(bitmap_id, x, y, opacity)
			return 103 if @framebuffer.nil?
			bitmap = ObjectSpace._id2ref(bitmap_id)
			bitmap_width = bitmap.width
			bitmap_height = bitmap.height
			framebuffer_width = @framebuffer.width
			framebuffer_height = @framebuffer.height
			min_width = [bitmap_width, framebuffer_width].min
			min_height = [bitmap_height, framebuffer_height].min
			x = x.to_i
			y = y.to_i
			x += bitmap_width if x < 0
			y += bitmap_height if y < 0
			return 111 if x < 0 || y < 0 || x >= min_width || x >= min_height
			opacity = opacity > 100 ? 255 : 0 unless @light_blending
			@framebuffer._kgl_subtract_rect(
				x,
				framebuffer_height - (min_height - y),
				bitmap,
				Rect.new(
					x,
					bitmap_height - (min_height - y),
					min_width - x,
					min_height - y,
				),
				opacity,
			)
			1
		end
	end

	# If the argument is nonzero, enable soft shadows, then return 1.
	# If the argument is zero, disable soft shadows, then return 1.
	class KglSoftShadows
		def call(enabled_integer)
			enabled = enabled_integer && enabled_integer != 0 ? true : false
			@soft_shadows = enabled
			1
		end
	end

	# If the KGL shadowbuffer is unbound, return 105.
	# If the KGL shadowbuffer is bound but y is less than 0, greater than or equal to the height of the KGL shadowbuffer or
	# exactly equal to half the height of the KGL shadowbuffer rounded down, return 111.
	# Otherwise, if x2 is less than x1, return 1.
	# Otherwise, cast a shadow of transparent black pixels from an invisible horizontal line segment with the given end points,
	# radially away from the center of the KGL shadowbuffer.
	# The actual line segment itself is not part of the shadow, so the shadow begins one pixel above or below the given y coordinate.
	# If the width or height of the shadowbuffer is even, the center is located at the smaller x or y coordinate.
	# Please note that the coordinate system uses the bottom-left corner as x = 0, y = 0, and x grows to the right and y grows upwards.
	# If soft shadows are enabled, there is an additional horizontal 3 pixel wide zone where the pixel components are
	# linearly interpolated between the original pixel value and transparent black.
	# After that, return 1.
	# For example, if the KGL shadowbuffer is initially 20 pixels by 20 pixels opaque, and
	# this function is called with x1 = 22, x2 = 40 and y = 16 with soft shadows enabled,
	# the result should be the following, where '.' represents fully opaque pixels, '#' represents fully transparent pixels,
	# '3' represents 25% opaque pixels, '2' represents 50% opaque pixels and '1' represents 75% opaque pixels.
	# If soft shadows are disabled, the partially opaque pixels are instead fully transparent.
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ..................................................
	#     ...................123#####################321....
	#     ..................123########################321..
	#     ..................123#########################321.
	#     ..................123###########################32
	#     .................123##############################
	#     .................123##############################
	#     .................123##############################
	#     ................123###############################
	#     ................123###############################
	#     ................123###############################
	#     ...............123################################
	#     ...............123################################
	#     ...............123################################
	#     ..............123#################################
	#     ..............123#################################
	#     ..............123#################################
	class KglShadowShaderH
		def call(x1, x2, y)
			return 105 if @shadowbuffer.nil?
			@shadowbuffer._kgl_shadow_shader_h(x1, x2, y, @soft_shadows) # TODO: implement this bitmap function
		end
	end

	# This is the same as ShadowShaderH but with a vertical line instead of a horizontal line.
	class KglShadowShaderV
		def call(y1, y2, x)
			return 105 if @shadowbuffer.nil?
			@shadowbuffer._kgl_shadow_shader_v(y1, y2, x, @soft_shadows) # TODO: implement this bitmap function
		end
	end

	# This is the same as ShadowShaderV except the shadow is cast horizontally instead of radially,
	# and the shadow is drawn as if soft shadows is disabled regardless of the actual value of the setting.
	class KglShadowShaderW
		def call(y1, y2, x)
			return 105 if @shadowbuffer.nil?
			@shadowbuffer._kgl_shadow_shader_w(y1, y2, x) # TODO: implement this bitmap function
		end
	end
end

class Win32API
	alias_method :kgl2_native_initialize, :initialize
	def initialize(dll, func, *args)
		@dll = dll
		@func = func

		func[0] = func[0].upcase

		begin
			if (dll == 'KGL2.klib' || dll.end_with?('/KGL2.klib') || dll.end_with?('\KGL2.klib')) && KGL2_Impl.const_defined?(func)
				@kgl2_wrap_impl = KGL2_Impl.const_get(func).new
				return
			end
		rescue Exception
		end

		kgl2_native_initialize(@dll, @func, *args)
	end

	alias_method :kgl2_native_call, :call
	def call(*args)
		if @kgl2_wrap_impl
			return @kgl2_wrap_impl.call(*args)
		end

		return kgl2_native_call(*args)
	end
end
