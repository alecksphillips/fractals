
function drawMandelbrotGPU(
  center::Tuple{Real,Real}=(-0.75,0),
  imageSize = (250,250),
  zoom=1,
  maxIters::Integer=100,
  bailout=2^8,
  colorDensity = 1,
  cmap = colormapFromTSV("colormap.tsv")
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
  iters = Array{Int,2}(undef, imageSize[2],imageSize[1])

  histogram = [0 for i in 1:maxIters]

  c = Array{Complex{Float32}, 2}(undef, imageSize[2], imageSize[1])
  for j in 1:imageSize[1]
    for i in 1:imageSize[2]
      relx = xmin + (j-0.5)*(xmax-xmin)/(imageSize[1])
      rely = ymin + (i-0.5)*(ymax-ymin)/(imageSize[2])
      c[i,j] = relx - rely*im
      #print("i: $i j: $j c: $c")
    end
  end

  d_c = CuArray(reshape(c,(imageSize[2]*imageSize[1])))
  #A = CuArray{Tuple{UInt8,Complex{Float32}},1,Nothing}(imageSize[2]*imageSize[1])
  d_iter = CuArray(reshape(iters, (imageSize[2]*imageSize[1])))
  d_z = similar(d_c)

  function m_gpu(c::Complex, maxIter)
    z = Complex(0.0, 0.0)
    for i in 1:maxIter
        abs2(z) > 4f0 && return ((i-1), z)
        z = z * z + c
    end
    return (maxIter, z)
  end

  #print("Starting CUDA...")
  #@cuda threads=imageSize[2]*imageSize[1] mandelbrot_gpu(d_c, d_iter, d_z, maxIters, bailout2)
  #print("Done\n")

  x = CuArray(Array{Tuple{UInt8,Complex{Float32}}}(undef, size(d_c)))

  print("Starting CUDA...")
    x .= m_gpu.(d_c, maxIters)
    GPUArrays.synchronize(x)
    d_iter = [a[1] for a in x]
    d_z = [a[2] for a in x]
    #d_z = [x[2] for x in A]
  print("Done\n")

  zs = reshape(Array(d_z), (imageSize[2], imageSize[1]))
  iters = reshape(Array(d_iter), (imageSize[2], imageSize[1]))

  print("[")
  for j in 1:imageSize[1]
    if j%(floor(imageSize[1]/50)) == 0
      print(".")
    #  print("$(Integer(floor(100*j/imageSize[1])))%\n")
    end
    for i in 1:imageSize[2]
      iter,z = iters[i,j],zs[i,j]
      #print("iter: ", iter, "  z: ",z,"\n")
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

  #print(maximum(itersReached))
  #print(length(cumSumHist))

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

#cmap = colormapFromTSV("colormap.tsv")

#@time img = mandelbrot((-0.75,0),(1600,900),1,1000,2^8)
#@time img = drawMandelbrot((-0.75,0),(2560+1920,1440),1,1000,2^8)
#save(File(format"PNG", "mandelbrot-wallpaper.png"), img)
#=k=0
for i in 0:0.05:32
  k+=1
  #if i%(1000/100) == 0
    #print("$(Integer(floor(100*i/1001)))%")

  #end
  #img = mandelbrot((-0.7436438885706,0.1318259043124),(1920,1080),75,i,2^8)
  #img = mandelbrot((-0.75,0),(1920,1080),1,i,2^8)
  mag = exp(i)
  #print("mag: $mag")
  img = mandelbrot((-0.743643887037151,0.131825904205330),(320,180),mag,5000,2^8)
  save(File(format"PNG","mandelbrot-$k.png"),img)
end

run('ffmpeg -framerate 30 -i mandelbrot-%d.png -c:v libx264 -r 30 out.mp4')
=#