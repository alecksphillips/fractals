include("buddhabrot.jl")

function nebulabrot(;
  imageSize = (500,500),
  maxIters = (5000,500,50),
  kwargs...
)

  channels = Array{Float64,3}(undef, (imageSize[1], imageSize[2] ,3))

  for i = 1:3
    channels[:,:,i] = drawBuddhabrot(
      imageSize = imageSize,
      maxIters = maxIters[i];
      kwargs...
    )
  end

  img = colorview(RGB, permutedims(channels,(3,1,2)))

  return img
end
