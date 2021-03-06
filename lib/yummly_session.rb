class YummlySession
  include HTTParty
  format :json
  APP_ID = ENV['YUMMLY_APPLICATION_ID']
  APP_KEY = ENV['YUMMLY_APPLICATION_KEY']

  def self.search(ingredients)
    options = {
      query: {
        # facets could be used to scrape additional ingredients: 'facetField[]' => 'ingredient',
        '_app_id' => APP_ID,
        '_app_key'=> APP_KEY,
        'maxResult' => 16,
        'q' => ingredients.join('+'),
        'requirePictures' => true 
      }
    }

    response = HTTParty.get("http://api.yummly.com/v1/api/recipes", options)
    p = JSON.parse(response.body)

    recipes = []

    p['matches'].each do |match|
      recipe = {
        title: match['recipeName'],
        ingredients: match['ingredients'].join('|'),
        small_image_url: match['imageUrlsBySize']['90'],
        total_time_in_seconds: match['totalTimeInSeconds'],
        source_display_name: match['sourceDisplayName'],
        yummly_id: match['id']

      }
      # fail
      recipes << recipe
    end

    recipes
  end

  def self.recipe(recipe_id)
    options = {
      query: {
        '_app_id' => APP_ID,
        '_app_key'=> APP_KEY,        
      }
    }

    response = HTTParty.get("http://api.yummly.com/v1/api/recipe/#{recipe_id}", options)
    raise 'no response from Yummly' unless response

    p = JSON.parse(response.body)

    {
      title: p['name'],
      credit: p['attribution']['html'],
      ingredients: p['ingredientLines'].join('|'),
      large_image_url: p['images'][0]['hostedLargeUrl'],
      small_image_url: p['images'][0]['hostedSmallUrl'],
      source_recipe_url: p['source']['sourceRecipeUrl'],
      source_site_url: p['source']['sourceSiteUrl'],
      source_display_name: p['source']['sourceDisplayName'],
      yummly_id: p['id'],
      total_time: p['totalTime'],
      total_time_in_seconds: p['totalTimeInSeconds']
    }
  end
end