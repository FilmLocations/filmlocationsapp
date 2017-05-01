# filmlocationsapp

### Description

Discover film locations nearby you in San Francisco. Visit the locations and share a picture with the community. Search for your favorite films and explore all of the filming locations.  

### User Stories
* Optional: User can sign in using OAuth login flow
[X] User can view a map displaying nearby movies based on his current location
    [X] on the bottom of the screen, a details list containing the movies that are pined on the map is displayed
    [X] each item in that list contains: movie’s poster, title, release year, address for that location as long as the distance from the current position to that point
    * optional: display time information and transportation
    * optional: show a button to request a ride (integration with Uber or Lift) 
    * as the user is navigating trough the bottom list by swiping left/right, the corresponding location for the selected movie is highlighted on the map
    * user can search for a specific movie
        * detail list shows all the locations on the map where that movie was filmed
        * each item in this case contains: a photo of the location, movie’s title, release year, the address, as long as the distance from the current location to that point 
    * by taping on a photo from detail list, seque to a detail page
        * user can see movie details
        * user can mark this place as seen
        * user can take photos and add notes
        * user can mark this place as favorite
        * optional: user can see a virtual tour for a few locations on the map - convert panoramic images into VR content (we can use gyro and accelerometer to show a VR tour, as the phone moves around)
        * optional: user can see how many people saw this place
        * optional: user can see how many people liked this place
        * optional: user can share photos taken on Twitter
    * places marked as seen are displayed with a different color on the map
    * user can zoom in/out
* User can view a list of movies
    * implement infinite scroll for movie results
    * user can search by a particular movie
    * selecting a movie from the list will expand the table view in order to show all the locations where that movie was filmed
    * by tapping location cell, a detail page similar to the one from the map view is displayed
    * optional: movies can be grouped in categories
* Optional: About screen contains 
    * link to the App Store where user can give feedback
    * information about development team

### Wireframes

[Wireframes](https://github.com/FilmLocations/filmlocationsapp/blob/master/wireframes/README.md)

[GIF](http://i.imgur.com/8570Ll1.gif)
