# Buddhdabrot example

include("fractals/buddhabrot.jl")

#Use a different number of max_iters for each color channel
maxIters = (5000,500,50)

imageSize = (500,500)
nSamples = 1e7

channels = Array{Float64,3}(undef, (imageSize[1], imageSize[2] ,3))


for i = 1:3
  channels[:,:,i] = drawBuddhabrot(
    imageSize = imageSize,
    maxIters= Integer(floor(maxIters[i])),
    bailout=3,
    N = nSamples
  )
end

img = colorview(RGB, permutedims(channels,(3,1,2)))

save(File{format"PNG"}("buddhabrot.png"), img)
