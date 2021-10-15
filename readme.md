<!--
  Created at: 09/24/2021 20:35:40 Friday
  Modified at: 10/15/2021 01:31:22 PM Friday

        Copyright (C) 2021 Thiago Ferreira
  See file "license" for details about copyright
-->

# Freenutritionfacts extractor

Extract data from freenutritionfacts.com

## Features

Data extracted
- [x] Food
	- [x] Grams considerated (normally is 100g)
	- [x] Category
	- [x] Total fat
	- [x] Energy
	- [x] Alcohol
	- [x] Nutrients
	  - [x] Carbohydrates
	  - [x] Sugar
	  - [x] Fiber
	  - [x] Protein
	  - [x] Caffeine
	  - [x] Water
	  - [x] Ash
	- [x] Vitamins
	  - [x] Vitamin A
	  - [x] Vitamin B1
	  - [x] Vitamin B2
	  - [x] Vitamin B3
	  - [x] Vitamin B5
	  - [x] Vitamin B6
	  - [x] Vitamin B9
	  - [x] Vitamin B12
	  - [x] Vitamin C
	  - [x] Vitamin D
	  - [x] Vitamin E
	  - [x] Vitamin K
	- [x] Minerals
	  - [x] Calcium
	  - [x] Iron
	  - [x] Phosphorus
	  - [x] Sodium
	  - [x] Copper
	  - [x] Magnesium
	  - [x] Potassium
	  - [x] Zinc
	  - [x] Fluorin
	  - [x] Manganese
	  - [x] Selenium

- [x] Category
  - [x] Name
  - [x] Foods

## TODO

- [ ] Parse unit instead saving string
- [ ] Use the `a[name="prop"]` in page
- [ ] make requests with `async`

## Info

### [Sitemap](http://www.freenutritionfacts.com/sitemap.index.xml)

http://www.freenutritionfacts.com/sitemap.index.xml

## License

MIT
