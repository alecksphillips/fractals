
function juliaIterations(c, juliaPoint, maxIters=1000, bailout = 2^8)
  z0 = c
  z = z0

  iter = 0

  #Cardioid Test
  #p = (real(c) - 0.25)^2 + imag(c)^2
  #Period-2 Bulb Test
  #q = (real(c)+1)^2 + imag(c)^2

  #if p <= 0.25*imag(c)^2 || q <= 1/16
  #    return maxIters,c
  #end

  bailout2 = bailout*bailout

  while ( abs2(z) < bailout2 && iter < maxIters)
    zstar = z^2 + juliaPoint
    if zstar == z
      iter = maxIters
    else
      z = zstar
      iter += 1
    end
  end

  return iter,z

end




function  mandelbrot(c, maxIters=1000, bailout = 2^8)
  z0 = 0 + 0im
  z = z0

  iter = 0

  #Cardioid Test
  p = (real(c) - 0.25)^2 + imag(c)^2
  #Period-2 Bulb Test
  q = (real(c)+1)^2 + imag(c)^2

  if p <= 0.25*imag(c)^2 || q <= 1/16
    return maxIters,c
  end

  bailout2 = bailout*bailout

  while ( abs2(z) < bailout2 && iter < maxIters)
    zstar = z^2 + c
    if zstar == z
      iter = maxIters
    else
      z = zstar
      iter += 1
    end
  end

  return iter,z

end

function mandelbrot_gpu(c, iters, z, maxIters, bailout2)
  i = threadIdx().x
  c1 = c[i]
  z0 = 0 + 0*im
  z1 = z0

  iter = 0

  #Cardioid Test
  p = (real(c1) - 0.25)^2 + imag(c1)^2
  #Period-2 Bulb Test
  q = (real(c1)+1)^2 + imag(c1)^2

  if p <= 0.25*imag(c1)^2 || q <= 1/16
    iters[i] = maxIters
    z[i] = c1
    return
  end

  while ( abs2(z1) < bailout2 && iter < maxIters)
    zstar = z1*z1 + c1
    if zstar == z1
      iter = maxIters
      break
    else
      z1 = zstar
      iter +=1
    end
  end

  iters[i] = iter
  z[i] = z1

  return
end



function  burningShip(c, maxIters=1000, bailout = 2^8)
  z0 = 0 + 0im
  z = z0

  iter = 0

  while ( abs2(z) < 4 && iter < maxIters)
    zstar = (abs(real(z)) + im*abs(imag(z)))^2 + c
    if zstar == z
      iter = maxIters
    else
      z = zstar
      iter += 1
    end
  end

  return iter,z

end