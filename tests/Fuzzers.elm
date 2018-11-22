module Fuzzers exposing (featureFuzzer, geoCollectionFuzzer)

import Angle
import Coordinates exposing (WGS84)
import Feature exposing (Feature(..))
import Fuzz exposing (Fuzzer, list)
import GeoCollection exposing (GeoCollection)
import LineString exposing (LineString(..))
import Point exposing (Point(..))
import Polygon exposing (LinearRing(..), Polygon(..))


geoCollectionFuzzer : Fuzzer a -> Fuzzer (GeoCollection WGS84 a)
geoCollectionFuzzer =
    list << featureFuzzer


shortNonEmptyList : Fuzzer a -> Fuzzer (List a)
shortNonEmptyList a =
    Fuzz.frequency
        [ ( 1, list a )
        , ( 20, Fuzz.map2 (\b c -> [ b, c ]) a a )
        , ( 79, Fuzz.map List.singleton a )
        ]


shortList : Fuzzer a -> Fuzzer (List a)
shortList a =
    Fuzz.frequency
        [ ( 4, list a )
        , ( 20, Fuzz.map2 (\b c -> [ b, c ]) a a )
        , ( 36, Fuzz.map List.singleton a )
        , ( 40, Fuzz.constant [] )
        ]


featureFuzzer : Fuzzer a -> Fuzzer (Feature WGS84 a)
featureFuzzer props =
    Fuzz.oneOf
        [ Fuzz.map2 Points (shortNonEmptyList pointFuzzer) props
        , Fuzz.map2 LineStrings (shortNonEmptyList lineStringFuzzer) props
        , Fuzz.map2 Polygons (shortNonEmptyList polygonFuzzer) props
        ]


wsg84Fuzzer : Fuzzer WGS84
wsg84Fuzzer =
    Fuzz.map2 WGS84 (Fuzz.map Angle.degrees (Fuzz.floatRange -90 90)) (Fuzz.map Angle.degrees (Fuzz.floatRange -180 180))


pointFuzzer : Fuzzer (Point WGS84)
pointFuzzer =
    Fuzz.map Point wsg84Fuzzer


lineStringFuzzer : Fuzzer (LineString WGS84)
lineStringFuzzer =
    Fuzz.map3 LineString wsg84Fuzzer wsg84Fuzzer (shortList wsg84Fuzzer)


polygonFuzzer : Fuzzer (Polygon WGS84)
polygonFuzzer =
    Fuzz.map2 Polygon linearRingFuzzer (shortList linearRingFuzzer)


linearRingFuzzer : Fuzzer (LinearRing WGS84)
linearRingFuzzer =
    Fuzz.map5 LinearRing wsg84Fuzzer wsg84Fuzzer wsg84Fuzzer wsg84Fuzzer (shortList wsg84Fuzzer)
