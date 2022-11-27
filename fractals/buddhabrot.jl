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
  N = 100,
  f::Function = mandelbrot,
  juliaSet = false,
  juliaPoint = 0.0 + 0.0*im,
  flip = "none",
  rotate = 90,
  kwargs...
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
  
  
  if rotate == 0
    img = Array{RGB{Float64},2}(undef,imageSize[2],imageSize[1])
    itersReached = Array{Float64,2}(undef,imageSize[2],imageSize[1])
    dens = zeros(Int64, imageSize[2], imageSize[1])
  elseif rotate == 90
    img = Array{RGB{Float64},2}(undef,imageSize[1],imageSize[2])
    itersReached = Array{Float64,2}(undef,imageSize[1],imageSize[2])
    dens = zeros(Int64, imageSize[1], imageSize[2])
  end

  histogram = [0 for i in 1:maxIters]

  print("[")
  for i = 1:N
    if i%floor(N/20) == 0
      print(".")
    end
    p = xmin + rand()*(xmax-xmin) + (ymin + rand()*(ymax-ymin))*im

    if juliaSet
      z0 = p
      c = juliaPoint 
    else
      c = p
      z0 = 0.0+0.0*im
    end
    curIter,z = iterateToEscape(z0, f = f, maxIters=maxIters, bailout = bailout, c = c, kwargs...)
    
    #Does this point escape?
    if curIter < maxIters
      z = z0
      for iter = 1:curIter
        z = f(z, c = c)
        z1 = z
        if (flip == "ud" || flip == "udlr")
          z1 = real(z1) - imag(z1)*im
        end
    
        if (flip == "lr" || flip == "udlr")
          z1 = -real(z1) + imag(z1)*im
        end
        p = complexToPixel(z1, xmin, xmax, ymin,ymax, imageSize)
        
        if p[1] > 0
          if rotate == 90
            dens[p[1],p[2]] += 1
          else 
            dens[p[2],p[1]] += 1
          end

          if Symbol(f) == Symbol("mandelbrot")
            #mandelbrot is symmetric
            p = complexToPixel(real(z1) - imag(z1)*im, xmin,xmax,ymin,ymax,imageSize)
            if p[1] > 0
              if rotate == 90
                dens[p[1],p[2]] += 1
              else 
                dens[p[2],p[1]] += 1
              end
            end
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



