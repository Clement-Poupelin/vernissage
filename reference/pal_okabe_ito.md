# Colour palettes

`pal_okabe_ito()` returns the nine colours of the Okabe-Ito palette
(Okabe & Ito 2008), safe for colour-blind readers. `pal_levels()` gives
one colour per level of a factor.

## Usage

``` r
pal_okabe_ito()

pal_levels(levels, palette = NULL)
```

## Arguments

- levels:

  Levels (character or factor levels) to colour.

- palette:

  See Details.

## Value

A named character vector of hexadecimal colours.

## Details

`palette` in `pal_levels()` can be:

- `NULL`: Okabe-Ito colours (orange, sky blue, green, vermillion, blue,
  pink, yellow, grey), interpolated when there are more levels;

- a named vector covering every level: returned as is (in level order);

- an unnamed vector of colours, used in order (interpolated if too
  short);

- the name of a palette: `"okabe"`, one of
  [`grDevices::hcl.pals()`](https://rdrr.io/r/grDevices/palettes.html),
  [`grDevices::palette.pals()`](https://rdrr.io/r/grDevices/palette.html)
  or an RColorBrewer palette;

- a function of the number of colours, e.g.
  [grDevices::rainbow](https://rdrr.io/r/grDevices/palettes.html).

## References

Okabe M, Ito K (2008). Color Universal Design (CUD): how to make figures
and presentations that are friendly to colorblind people.

## Examples

``` r
pal_okabe_ito()
#>     orange    skyblue      green     yellow       blue vermillion       pink 
#>  "#E69F00"  "#56B4E9"  "#009E73"  "#F0E442"  "#0072B2"  "#D55E00"  "#CC79A7" 
#>       grey      black 
#>  "#999999"  "#000000" 
pal_levels(c("Placebo", "Active"))
#>   Placebo    Active 
#> "#E69F00" "#56B4E9" 
pal_levels(c("A", "B", "C"), palette = "Dark 3")
#>         A         B         C 
#> "#E16A86" "#50A315" "#009ADE" 
pal_levels(c("Low", "High"), palette = c(Low = "grey70", High = "firebrick"))
#>         Low        High 
#>    "grey70" "firebrick" 
```
