using Images, VideoIO

include("fractals/iterationFunctions.jl")
include("fractals/mandelbrot.jl")

fps = 60
videoLength = 5
cycles = 1
real_cycles = 3
im_cycles = 4
radius_cycles = 5
phase_offset = π/2
frames = fps*videoLength

imageSize = (500,500)

juliaCenter = 0 + 0*im
juliaRadius = 2


images = fill(Array{RGB{N0f8},2}(undef,imageSize),frames)

for i in 1:frames
  angle = (i-1)/frames * 2π * cycles
  juliaPoint = juliaCenter + juliaRadius*(cos(angle*real_cycles + + phase_offset)  + sin(angle*im_cycles) * im)

  images[i] = drawEscapeTimeFractal(
    center = (0,0),
    imageSize = imageSize,
    maxIters = 1000,
    f = juliaPolynomial,
    juliaPoint = juliaPoint,
    zoom = 0.5
  )
end


encoder_options = (crf=23, preset="medium")
VideoIO.save("julia.mp4", images, framerate=fps, encoder_options=encoder_options)
