#Mandelbrot drawing
using Images, Colors, FixedPointNumbers, FileIO

include("iterationFunctions.jl")
include("util.jl")

function drawBuddhabrot(;
  center::Tuple{Real,Real}=(-0.75,0),
  imageSize = (250,250),
  zoom=1,
  maxIters::Integer=100,
  bailout=3,
  N = 100
)

  #default = (-2.5,1,-1.75,1.75)
  defaultScale = 1.75

  #Quicker to evaluate squared absolute value of complex number
  bailout2 = bailout*bailout

  #xmin,xmax,ymin,ymax = area
  #center = (center[,center[1])

  imageSize = (imageSize[1],imageSize[2])
  if imageSize[1] > imageSize[2]
    aspectRatio = imageSize[1]/imageSize[2]
    xmin = center[1] - defaultScale*aspectRatio/zoom
    xmax = center[1] + defaultScale*aspectRatio/zoom
    ymin = center[2] + defaultScale/zoom
    ymax = center[2] - defaultScale/zoom
  else
    aspectRatio = imageSize[2]/imageSize[1]
    xmin = center[1] - defaultScale/zoom
    xmax = center[1] + defaultScale/zoom
    ymin = center[2] + defaultScale*aspectRatio/zoom
    ymax = center[2] - defaultScale*aspectRatio/zoom
  end
  #print("Aspect Ratio: $aspectRatio\n")
  img = Array{RGB{Float64},2}(undef,imageSize[2],imageSize[1])
  itersReached = Array{Float64,2}(undef,imageSize[2],imageSize[1])


  histogram = [0 for i in 1:maxIters]

  dens = zeros(Int64, imageSize[2], imageSize[1])

  #guidict = ImageView.imshow(dens)
  #canvas = guidict["gui"]["canvas"]

  print("[")
  for i = 1:N
    if i%floor(N/20) == 0
      print(".")
    end
    c = xmin + rand()*(xmax-xmin) - (ymin + rand()*(ymax-ymin))*im
    curIter,z = mandelbrot(c, maxIters, bailout)
    #curIter,z = burningShip(c, maxIters, bailout)
    #Does this point escape?
    if curIter < maxIters
      #Add points of orbit to image
      z = 0 + 0im
      for iter = 1:curIter
        #z = (abs(real(z)) + im*abs(imag(z)))^2 + c
        z = z*z + c
        p = complexToPixel(z, xmin, xmax, ymin,ymax, imageSize)
        if p[1] > 0
          dens[p[2],p[1]] += 1
          p = complexToPixel(real(z) - imag(z)*im, xmin,xmax,ymin,ymax,imageSize)
          if p[1] > 0
            dens[p[2],p[1]] += 1
          end
        end
      end
    else
      #Carry on (my wayward son)
    end
  end
  print("]")

  dens/maximum(dens)

end
