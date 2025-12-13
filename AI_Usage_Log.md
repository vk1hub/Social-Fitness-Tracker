December 12 - ChatGPT

"How do I go about removing shared preferences and moving to firebase storage?"
It told me to stop saving workouts with shared preferences and to instead save
data to firebase.

It was applied by removing the previous shared preferences code and
going forward with implementing firebase.

I learned that the data from shared preferences is no longer used and
that it's basically useless. Functionality works with new data.

------

December 12 - ChatGPT

"How do I link firebase auth to show user information?"
It gave me a response on how to link the firebase data
to the UI and properly update the information. I was having
issues with data not updating correctly.

It was applied by properly showing user data on their
profile page by transferring from shared_preferences to
firebase storage.

I learned that showing user data is simple, and accounting for
update logic is important. (deleting / modifying workouts)

------

December 13 - ChatGPT

"how do i implement the image picker into a flutter project? My images are not saving"
It gave me a response on the documentation for implementing in an image picker
and uploader using the dependency. My images were also not saving properly.

It was applied by adding an image picker dependency in pubsec.yaml
and saving the image properly.

I learned that I needed to go to firebase and enable storage since my
photos were not saving properly to firebase. I also had to update the
AndroidManifest file to request permission for uploading photos.


