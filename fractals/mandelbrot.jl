#Mandelbrot drawing
using Images, Colors, FixedPointNumbers, FileIO

include("colormapFromTSV.jl")
include("iterationFunctions.jl")
include("util.jl")

function drawEscapeTimeFractal(;
  center::Tuple{Real,Real}=(-0.75,0),
  imageSize = (250,250),
  zoom=1,
  maxIters::Integer=100,
  bailout=2^8,
  colorDensity = 1,
  cmap = colormapFromTSV("colormap.tsv"),
  f::Function = mandelbrot,
  juliaSet = false,
  juliaPoint = 0.0 + 0.0*im,
  flip = "none",
  rotate = "none",
  kwargs...
)

  defaultScale = 1.75

  #Quicker to evaluate squared absolute value of complex number
  bailout2 = bailout*bailout

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
  print("[")
  for j in 1:imageSize[1]
    if j%(floor(imageSize[1]/50)) == 0
      print(".")
    #  print("$(Integer(floor(100*j/imageSize[1])))%\n")
    end

    for i in 1:imageSize[2]
      p = pixelToComplex((j,i), xmin, xmax, ymin, ymax, imageSize)
      if (flip == "ud" || flip == "udlr")
        p = real(p) - imag(p)*im
      end

      if (flip == "lr" || flip == "udlr")
        p = -real(p) + imag(p)*im
      end

      if juliaSet
        z0 = p
        c = juliaPoint 
      else
        c = p
        z0 = 0.0+0.0*im
      end
        
      iter,z = iterateToEscape(
        z0,
        maxIters=maxIters,
        bailout = bailout,
        f = f,
        c = c,
        kwargs...
      )
      histogram[iter] += 1
      if iter < maxIters
        logzn = log(real(z)*real(z) + imag(z)*imag(z))/2
        nu = log(logzn/log(2))/log(2)
        #print("nu: $nu\n")
        iter = iter + 1 - nu
      end

      itersReached[i,j] = iter*colorDensity

    end
  end
  print("]\n")

  #print("Min itersReached: $(minimum(itersReached))\n")
  cumSumHist = cumsum(histogram[1:size(histogram,1)-1])
  total = sum(histogram[1:size(histogram,1)-1])
  nColors = size(cmap)[1]

  print(maximum(itersReached))
  print(length(cumSumHist))

  for j in 1:imageSize[1]
    for i in 1:imageSize[2]

      if itersReached[i,j] < maxIters*colorDensity
        
        iter = Integer(floor(itersReached[i,j]))
        q = itersReached[i,j]%1

        y1 = iter%nColors + 1
        y2 = (iter +  1)%nColors + 1

        c1 = cmap[y1]
        c2 = cmap[y2]

        #if q < 0.5
      #    img[i,j] = RGB(1-q,1-q,1-q)
    #    else
    #      img[i,j] = RGB(q,q,q)
    #    end
      #    img[i,j] = weighted_color_mean(q,c2,c1)
    #    else
  #        img[i,j] = weighted_color_mean(q,c1,c2)
#        end

        img[i,j] = weighted_color_mean(q,c2,c1)

      else
        img[i,j] = RGB(0,0,0)
      end




    end
  end
  img
end


