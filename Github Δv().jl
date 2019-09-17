# Timothy Gaede
# 2019-09-16
# TimGaede@gmail.com

using Formatting


#-------------------------------------------------------------------------------
# Yields the result of a Δv from a rocket in a circular
# orbit about a planet that is either at perihelion or aphelion.
# Isp (specfic impulse) is in standard units of seconds
# mᵢ_to_m is the initial-to-final rocket mass ratio
#
# Unless otherwise implied, all physical units are of the kms system
#
function Δv(name, at_perihelion, alt_km, Isp, mᵢ_to_m, Δv_in_planet_direction)

    if mᵢ_to_m < 1
        return "The mass ratio must be at least 1.0"
    end

    #...........................................................................
    function SolarOrbitInfo(rₚ_rk_☉, rₐ_rk_☉)
        μ☉ = 1.327124400189 * 10.0^20 # Sun
        a🜨 = 149_598_023.0k # semi-major axis
        yr = τ*√(a🜨^3 / μ☉)

        a = (rₐ_rk_☉ + rₚ_rk_☉) / 2 # semi-major axis
        T = τ*√(a^3 / μ☉) # orbital period

        T_yr = T / yr
        numDecimals = 4 - convert(Int, floor(log10(T_yr)))

        if numDecimals > 0
            strT = format(T_yr, precision=numDecimals) * " years"
        else
            strT = format(T_yr, commas=true) * " years"
        end

        rₚ_AU = rₚ_rk_☉ / AU # perihelion in AU
        rₐ_AU = rₐ_rk_☉ / AU # aphelion in AU



        decimals_Pr = 4 - convert(Int, floor(log10(rₚ_AU)))
        if decimals_Pr ≥ 1
            strPr = format(rₚ_AU, precision=decimals_Pr) * " AU"
        else
            rₚ_AU = convert(Int, floor(rₚ_AU))
            strPr = format(rₐ_AU, commas=true) * " AU"
        end


        decimals_Ap = 4 - convert(Int, floor(log10(rₐ_AU)))
        if decimals_Ap ≥ 1
            strAp = format(rₐ_AU, precision=decimals_Ap) * " AU"
        else
            rₐ_AU = convert(Int, floor(rₐ_AU))
            strAp = format(rₐ_AU, commas=true) * " AU"
        end



        "The rocket will orbit the Sun " *
        "with a period of \n" * strT * ".\n\n" *
        "Its perihelion will be " * strPr * "." * "\n" *
        "Its aphelion will be   " * strAp * "."
    end
    #...........................................................................



    τ = 2π
    k = 1000
    #alt_LEO = 200k # altitude (height above surface) at Low Earth Orbit
    hr = 60*60
    day = 24hr
    AU = 149_597_870_700.0

    # The standard gravitational parameter, μ is equal to GM
    # μ is much more accurately known than either G or M.  Think about it.

    μ☉ = 1.327124400189 * 10.0^20 # Sun

    # Earth
    μ🜨 = 3.9860044188   * 10.0^14
    a🜨 = 149_598_023.0k # semi-major axis
    e🜨 = 0.0167086      # eccentricity
    R🜨 = 6378.1k        # equatorial radius



    # Mars
    μ♂ = 4.2828372  * 10.0^13
    a♂ = 227_939_200.0k
    e♂ = 0.0934
    R♂ = 3396.2k

    yr = τ*√(a🜨^3 / μ☉)



    if lowercase(name) == "earth"  ||  name == "🜨"
        μ◐ = μ🜨
        a◐ = a🜨
        e◐ = e🜨
        R◐ = R🜨
    elseif lowercase(name) == "mars"  ||  name == "♂"
        μ◐ = μ♂
        a◐ = a♂
        e◐ = e♂
        R◐ = R♂
    else
        msg = "Invalid value for the argument, \"name\", " *
              "passed to function Δv()"
        throw(msg)
    end




    rₒ_rk_◐ = R◐ + k*alt_km
    vₒ_rk_◐ = √(μ◐ / rₒ_rk_◐) # speed of rocket wrt the planet while in orbit

    Δv_rk_◐ = 9.80665*Isp*log(mᵢ_to_m) # change in speed of rocket


    # Speed of rocket immediately after the engines finished their burn
    vₚ_rk_◐ = vₒ_rk_◐ + Δv_rk_◐

    # velocity ratio of the rocket to a
    # would-be circular orbit at the same distance from the Sun
    n = vₚ_rk_◐ / vₒ_rk_◐
    n² = n^2


    if n² < 2 # Orbits the Planet


        rₐ_rk_◐ = rₒ_rk_◐ * n² / (2 - n²) # apoapsis
        a = (rₐ_rk_◐ + rₒ_rk_◐) / 2 # semi-major axis
        T = τ*√(a^3 / μ◐) # orbital period

        if T < 10hr
            strT = format((T / hr), precision=5) * " hours"
        elseif T < 72hr
            strT = format((T / hr), precision=4) * " hours"
        elseif T < 10day
            strT = format((T / day), precision=5) * " days"
        else
            strT = format((T / day), precision=4) * " days"
        end

        alt_ap_km = (rₐ_rk_◐ - R◐) / k # altitude at apoapsis in km


        if alt_ap_km < 1000
            strAlt = format(alt_ap_km, precision=2) * " km"
        elseif alt_ap_km < 10k
            strAlt = format(alt_ap_km, precision=1) * " km"
        elseif alt_ap_km < 100k
            alt_ap_km = convert(Int, floor(alt_ap_km))
            strAlt = format(alt_ap_km, commas=true) * " km"
        else
            return "The rocket has entered an unstable orbit\n" *
                   "about the the planet."
        end
        "The rocket will orbit $name with a period of \n" *
        strT * "\n\n" *
        "Its maximum altitude will be " * strAlt * "."

    elseif n² > 2 # Rocket escapes the planet.  Will it escape the Solar System?

        vₑ_rk_◐ = √2vₒ_rk_◐  # escape speed from LEO


        at_perihelion    ?    r◐ = a◐ * (1 - e◐)    :    r◐ = a◐ * (1 + e◐)


        v_◐_☉ = √(μ☉ / r◐) # Speed of planet orbit around Sun
        v_rk_◐ = √(vₚ_rk_◐^2 - vₑ_rk_◐^2) # wrt the planet



        if Δv_in_planet_direction

            vₚ_rk_☉ = v_◐_☉ + v_rk_◐ # wrt Sun
            rₚ_rk_☉ = r◐ + rₒ_rk_◐ # perihelion of rocket wrt sun

            # speed of what would be a circular orbit
            # about the Sun at rocket's perihelion
            v○_rk_☉ = √(μ☉ / rₚ_rk_☉)
            #

            N = vₚ_rk_☉ / v○_rk_☉ # velocity ratio
            N² = N^2

            if N² < 2 # Rocket orbits the Sun
                if Δv_in_planet_direction
                    rₚ_rk_☉ = r◐ + rₒ_rk_◐ # perihelion of rocket wrt sun
                    rₐ_rk_☉ = rₚ_rk_☉ * N² / (2 - N²) # aphelion
                else
                    rₐ_rk_☉ = r◐ - rₒ_rk_◐ # aphelion of rocket wrt sun
                    rₚ_rk_☉ = rₐ_rk_☉ * (2 - N²) / N² # perihelion
                end

                SolarOrbitInfo(rₚ_rk_☉, rₐ_rk_☉)

            elseif N² > 2 # Rocket escapes the Solar System
                vₑ_◐_☉ = √2v_◐_☉ # Escape speed from Sun at one AU
                v∞_rk_☉ = √(vₚ_rk_☉^2 - vₑ_◐_☉^2) # Asymptopic speed
                v_AUperYr = v∞_rk_☉ / (AU / yr)

                numDecimals = 4 - convert(Int, floor(log10(v_AUperYr)))
                if numDecimals > 0
                    strAUperYr = format(v_AUperYr, precision=numDecimals) *
                                 " AU per year"
                else
                    return "We're getting relativistic."
                end

                "The rocket will escape the Solar System\n" *
                "with a speed that " * "asymptotically approaches\n\n" *
                strAUperYr * "."

            else # N² == 2
                "Wow!\n\n" *
                "The rocket is right at the escape velocity of " *
                "the Solar System!"

            end
        else # backward
            if v_rk_◐ ≥ v_◐_☉
                return "Δv was too large.  Orbit is retrograde about the Sun\n"
            end
            vₐ_rk_☉ = v_◐_☉ - v_rk_◐
            rₐ_rk_☉ = r◐ - rₒ_rk_◐ # aphelion of rocket wrt sun

            # speed of what would be a circular orbit
            # about the Sun at rocket's aphelion
            v○_rk_☉ = √(μ☉ / rₐ_rk_☉)
            #

            X = vₐ_rk_☉ / v○_rk_☉ # velocity ratio at aphelion
            X² = X^2

            rₚ_rk_☉ = rₐ_rk_☉ * X² / (2 - X²) # perihelion

            SolarOrbitInfo(rₚ_rk_☉, rₐ_rk_☉)
        end

    else # n² == 2
        "Wow!\n\n" *
        "The rocket is right at the escape velocity of " * name * "!"
    end
end
#-------------------------------------------------------------------------------


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function main()
    println("\n", "-"^40, "\n")
    planet = "Earth"
    atPeri = true
    alt_km = 200
    Isp = 380
    mᵢ_to_m = 3.24
    Δv_in_planet_direction = true

    println(Δv(planet, atPeri, alt_km, Isp, mᵢ_to_m, Δv_in_planet_direction))
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
main()
