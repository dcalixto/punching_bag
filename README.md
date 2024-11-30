# PunchingBag

![Punch Bag](./src/punching-bag.gif)

A Crystal shard for tracking and analyzing hit counts, trending items, and time-based analytics.

## Features

- Total hit count tracking
- Most hit items tracking
- Time-based hit analytics
- Lightweight and fast

## Requirements

- Crystal >= 1.0.0

## Installation

1. Add PunchingBag to your `shard.yml`:

```yaml
dependencies:
  punching_bag:
    github: dcalixto/punching_bag
```

2. Install dependencies:

```crystal
shards install
```

3. Run setup:

```crystal
  crystal run bin/punching_bag.cr -- setup
```

## Usage

Import the library

```crystal
require "punching_bag"
```

Basic Hit Tracking

# Initialize

```crystal
bag = PunchingBag.new
```

Record a hit

```crystal
bag.punch("Article", 1)
```

Record multiple hits

```crystal
bag.punch("Article", 1, hits: 5)
```

Record hit with timestamp

```crystal
bag.punch("Article", 1, timestamp: Time.utc - 1.day)
```

# Analytics

Get total hits for an item

```crystal
total = bag.total_hits("Article", 1)
```

Get most hit items since last week

```crystal
trending = bag.most_hit(Time.utc - 1.week)
```

Get top 10 most hit items since last month

```crystal
top_items = bag.most_hit(Time.utc - 1.month, limit: 10)
```

Get average time for hits

```crystal
avg_time = bag.average_time("Article", 1)
```

## Configuration

```crystal
PunchingBag.configure do |config|
   config.database_url = "sqlite3:///custom/path/database.db"
end
```

Clear all recorded hits

```crystal
bag.clear
```

Example Integration

```crystal
class Article
   property id : Int32
   property title : String

  def track_view
    bag = PunchingBag.new
    bag.punch("Article", id)
  end

  def total_views
     bag = PunchingBag.new
    bag.total_hits("Article", id)
  end
end

```

## Development

```crystal
crystal spec
```

## Contributing

1. Fork it (https://github.com/dcalixto/punching_bag/fork)
2. Create your feature branch (`git checkout -b my-feature`)
3. Commit your changes (`git commit -am 'Add feature'`)
4. Push to the branch (`git push origin my-feature`)
5. Create a new Pull Request

## License

MIT License. See LICENSE for details.
