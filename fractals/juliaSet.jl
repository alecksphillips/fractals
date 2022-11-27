#Mandelbrot drawing
using Images, ImageView, Colors, FixedPointNumbers, FileIO

include("iterationFunctions.jl")
include("util.jl")
include("colormapFromTSV.jl")

function drawJulia(;
  center::Tuple{Real,Real}=(-0.75,0),
  imageSize = (250,250),
  juliaPoint = 0.0 + 0.0*im,
  zoom=1,
  maxIters::Integer=100,
  bailout=2^8,
  colorDensity = 1,
  cmapfile = "colormap.tsv"
)

  cmap = colormapFromTSV(cmapfile)

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

      c = pixelToComplex((i,j), xmin, xmax, ymin, ymax, imageSize)
      #relx = xmin + (j-0.5)*(xmax-xmin)/(imageSize[1])
      #rely = ymin + (i-0.5)*(ymax-ymin)/(imageSize[2])
      #c = relx + rely*im
      #print("i: $i j: $j c: $c")

      iter,z = juliaIterations(c; juliaPoint=juliaPoint, maxIters=maxIters, bailout=bailout)
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
        #print("itersReached: ", itersReached[i,j], "\n")

        #x1 = cumSumHist[iter]/total
        #x2 = cumSumHist[iter+1]/total

        q = itersReached[i,j]%1

        y1 = iter%nColors + 1
        y2 = (iter +  1)%nColors + 1



         #print("y1: ", y1, "\n")
         #print("y2: ", y2, "\n")

        c1 = cmap[y1]
        c2 = cmap[y2]

        img[i,j] = weighted_color_mean(q,c2,c1)

      else
        img[i,j] = RGB(0,0,0)
      end




    end
  end
  img,cmap
end
