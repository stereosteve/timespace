# Steps

  - seed json files with various timeline data
  - Backbone client to load the json and draw timeline


## Example Timelines

  - Years: Life of Oppenheimer - or - the development of the atomic bomb
  - Months: Presidential elections - separate timeline for each candidate
  - Days: Apollo 13
  - Hours: Football game

## Where to start

  vertical line running down page
  height of container is `timeline.duration * SCALE`
  
  container is fixed position to 0 40
  dots are absolute positioned `event.timestamp * SCALE`

  dots have short name and time next to them
  hover to see more details

## Prior art

  - TimeGlider
  - Dipity
  - Simile Timeline Widget


