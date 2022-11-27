include("fractals/mandelbrot.jl")
img = drawEscapeTimeFractal(center=(-0.95,0.3), imageSize=(10240,2880), zoom=20, maxIters=1000, bailout=5, colorDensity=0.05);
save(File{format"PNG"}("mandelbrot-wallpaper.png"), img)
