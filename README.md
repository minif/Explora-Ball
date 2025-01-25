# Explora-Ball
This is an iPhone OS 2.0 game, made to run on the original iPhones and iPods that released during this time. Use the accelerometer to move balls into the goal to move onto the next level. This game features 75 levels, with different mechanics to explore.

[Title screen](https://github.com/minif/Explora-Ball/blob/main/Screenshots/Title.PNG?raw=true)

### Compatibility
This game is made to run on 32-bit iOS devices. However, it has been made with [touchHLE](https://touchhle.org) support in mind. The specific compatibility for this game is:
- iPhone OS 2.0 to iOS 10.3.4, for iPhone, iPad, and iPod Touch
- touchHLE v0.2.2 and later, for Windows, Mac, and Android

Known issues with this game include:
- iOS 7.0 and later may experience issues with the Accelerometer. (Touch controls still work perfectly)
- Certain android devices running touchHLE may experience graphical issues, that will make the game unplayable
  - For certain devices, switching between native OpenGL ES 1.1 and ANGLE implementations may resolve this issue

### Playing the game
- Choose between three gamemodes
  - Freeplay (Initially locked): Allows you to start on any level, with four balls.
  - Play: Start at the first level with four balls, or resumes the last unlocked level pack.
  - Arcade: Start at the first level with four balls, without the ability to start at a later level.
- Tilt the device left and right to move the balls. Get the balls to the goal to move onto the next stage
  - You may enable touch controls if desired. If so, touch the left side of the screen or the right side of the screen to move the balls.
- All balls that make it to the goal move onto the next stage. If no balls make it to the goal, the game is over.
- There are 75 levels in the game, split between 5 worlds with different backgrounds and mechanics.
- Each world is divided into three level packs, and every new level pack gives 2 more balls.
- Make it to the end of the game to unlock Freeplay mode

### touchHLE reccomendations
It is reccomended to add the following line to your `touchHLE_options.txt` configuration to enable better support:
`com.minif.ExploraBall: --landscape-left --x-tilt-range=120 --button-to-touch=Start,470,10 --button-to-touch=DPadLeft,10,100 --button-to-touch=DPadRight,470,100`

### Building 
This game was build in Xcode 3.1.2 using the original iPhone OS 2.0 SDK. Unless you somehow have a working Apple Developer certificate for this version of Xcode, The game requires a Self-Signed Certificate in order to build, or for code signing to be disabled. The game is build by selecting Build and Go, or any other Build option in Xcode. 

### Features to be implemented 
Note that none of these features have any plans, this is more of a wish list for later:
- Fix accelerometer on later devices
- Image loading on startup
- Fix various physics bugs (i.e. slope not bouncing ball up enough, freezing when mixing moving objects and the goal)
- Implement better texture loading than pvrtc
- Implement music
