-module(concerts).

-export([get_random_concert/0]).

-type 'Genre'() ::
    'ALL' |
    'SYMPHONIC_METAL' |
    'MELODIC_DEATH_METAL' |
    'POWER_METAL' |
    'THRASH_METAL' |
    'ACAPELLA_METAL' |
    'PROG_METAL'.

-define(Cities, ["Kraków", "Katowice", "Wrocław", "Łódź", "Warszawa", "Poznań", "Gdańsk", "Toruń"]).
-define(Bands, [{"Epica", 'SYMPHONIC_METAL'}, {"Nightwish", 'SYMPHONIC_METAL'}, {"Delain", 'SYMPHONIC_METAL'},
                {"Amon Amarth", 'MELODIC_DEATH_METAL'}, {"Arch Enemy", 'MELODIC_DEATH_METAL'}, {"Dark Oath", 'MELODIC_DEATH_METAL'},
                {"Sabaton", 'POWER_METAL'}, {"Blind Guardian", 'POWER_METAL'}, {"Hammerfall", 'POWER_METAL'},
                {"Metallica", 'THRASH_METAL'}, {"Anthrax", 'THRASH_METAL'}, {"Slayer", 'THRASH_METAL'},
                {"Van Canto", 'ACAPELLA_METAL'}, {"Ayreon", 'PROG_METAL'}, {"Symphony X", 'PROG_METAL'}]).

%% return randomly-generated {{band, genre}, city} tuple
get_random_concert() -> {get_random_band(), get_random_city()}.

get_random_city() -> lists:nth(rand:uniform(length(?Cities)), ?Cities).

get_random_band() -> lists:nth(rand:uniform(length(?Bands)), ?Bands).