# Project Setup Instructions

__Create and launch the vagrant box__

	git git@github.com:cloudspace/rss.cloudspace.com.git
    cd ./rss.cloudspace.com
    librarian-chef install
    vagrant up

__Environment Variables__ - You will need to obtain a .env file and place it in the root of the project. This contains passwords that cannot be committed to the repo. Use `.env.sample` as a template.

__After the box is up, `vagrant ssh`__

    sudo apt-get install postgresql-server-dev-9.3
    sudo gem install bundler
    cd /srv/rss.cloudspace.com
    bundle
    rake db:setup
    rails s

***

#API Specification

## Entities

### feed
<small>Represents a `Feed` object, where `feed_items` is an array of up to 10 of the most recent feed_item entities associated with this feed.</small>

    {
    	"id": 16,
    	"name": "Engadget",
    	"url": "http://www.engadget.com/rss.xml",
    	"icon": "http://s3.amazonaws.com/rss.cloudspace.com/feed/16/icon.png",
    	"feed_items": [...]
    }

### feed_item
<small>Represents a `FeedItem` object. Associated with a feed.</small>

    {
        "id": 255,
        "feed_id": 16,
        "title": "Lorem ipsum dolor sit amet",
        "summary": "Ut enim ad minim veniam, quis nostrud exercitation ullamco",
        "author": "Fred Flintstone",
        "image_iphone_retina": "https://s3.amazonaws.com/rss.cloudspace.com/feed_items/255/iphone_retina.jpg",
        "image_ipad": "https://s3.amazonaws.com/rss.cloudspace.com/feed_items/255/ipad.jpg",
        "image_ipad_retina": "https://s3.amazonaws.com/rss.cloudspace.com/feed_items/255/ipad_retina.jpg",
    	"url": "http://engadget.com/articles/lorem.html",
    	"created_at": "2014-03-05T22:32:32+00:00",
    	"updated_at": "2014-03-05T22:32:32+00:00",
    	"published_at": "2014-03-04T19:52:13+00:00"
    }

---
## Routes

##### `GET /v2/feeds/default`
<small>Returns an array of curated feed entities. This will only be used on the first run of the app immediately after installation</small>

__Parameters__

- This route takes no parameters

__Returns__


    {
        feeds: [...]
    }

- HTTP 200 and an array of feed entities

---
##### `GET /v2/feeds/:id`
<small>Returns a single feed entity.</small>

__Parameters__

- _Required_ `id` - The id of the feed to be returned

__Returns__


    {
        feeds: [...]
    }

- HTTP 200 and an array containing a single feed entity if the feed exists
- HTTP 404 if the feed specified does not exist

---
##### `GET /v2/feeds/search`
<small>Searches through available feeds based on supplied parameters.</small>

__Parameters__

- _Required_ `name` - used to find a partial or complete match to a feed's name attribute

__Returns__

    {
        feeds: [...]
    }

- HTTP 200 and an array of feed entities (empty if no matches are found)
- HTTP 400 if no `name` parameter is provided

---
##### `POST /v2/feeds`
<small>Submits a feed to the API, which then attempts to parse it and return an array containing a single feed object.</small>

__Parameters__

- _Required_ - an `url` parameter, the address of the RSS feed

__Returns__

		{
				feeds: [...]
		}

- HTTP 200 if a feed with the specified `url` previously existed
- HTTP 201 if a feed with the specified `url` did not previously exist in the database and the feed is successfully parsed and created
- HTTP 422 (Unprocessable Entity) if `url` cannot be parsed as a feed
- HTTP 400 if no `url` parameter is provided or the request is bad for any other reason
- If the feed already exists and is parsed, returns up to 10 `feed_item` entities
- If the feed did not previously exist, return the feed entity with an empty `feed_items` array

---
##### `GET /v2/feed_items`
<small>Returns (up to) the most recent 10 `feed_item` entities (created since the date specified) for each feed specified.</small>

__Parameters__

- _Required_ `feed_ids` - an array of integers representing the feeds requested
- _Optional_ `since` - a lower bound for the age of `feed_item`s to be returned

__Returns__

    {
        feeds_items: [...],
        bad_feed_ids: [...]
    }

- HTTP 200 and an array of `feed_items` if all feeds are found
- HTTP 206 and arrays of both `feed_items` and `bad_feed_ids` if some but not all feeds were found
- HTTP 404 if none of the feed_ids provided were found


# Running the parser

From any rails console the feed/feeditem parser supervisor can be created as follows:

    supervisor = Service::Supervisor.new

Once created you can start any number of worker threads using `start_workers`.  To start up 8 workers (our determined optimum number for an EC2 large instance) the command would be:

    supervisor.start_workers(8)
    
Once started, the workers will fetch and parse feeds and feed items as well as cull the database so that only a reasonable amount of feed items are kept.