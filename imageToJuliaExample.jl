using Images, VideoIO

include("orbitalJulia.jl")

sourceImage = load("dog.png")

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
juliaRadius = 1


images = fill(Array{RGB{N0f8},2}(undef,imageSize),frames)

for i in 1:frames
  angle = (i-1)/frames * 2π * cycles
  
  juliaPoint = juliaCenter + juliaRadius*(cos(angle*real_cycles + + phase_offset)  + sin(angle*im_cycles) * im)

  images[i],map = drawJuliaImage(
    center = (0,0),
    sourceImage = sourceImage,
    imageSize = imageSize,
    maxIters = 1000,
    juliaPoint = juliaPoint,
    sourceImageLocation = 0 + 0.0*im,
    sourceImageScale = 2
  )
end


encoder_options = (crf=23, preset="medium")
VideoIO.save("doggo.mp4", images, framerate=fps, encoder_options=encoder_options)
