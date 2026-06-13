# Swan (SWCDN Browser)

Swan is a modern browser of macOS's SWCDN (Software Content Delievery Network). Apple uses it to distribute some of their update files, like their InstallAssistant.pkg files that contain the entire macOS installer including a copy of macOS, which can be used to create macOS installer/recovery USBs. There's much more in there, for example, the command line tools, macOS security updates, bridgeOS updates, BootCamp files, and many other things. This is meant as a modern replacement for older and less intuitive tools. 

This is in public alpha. It was started a while ago, and has been floating around in private beta for a while, so I decided to make it public. It doesn't have everything I've wanted for it (ex. IPSW browsing), but it's a solid start and works for what it does right now. I would love to know if this becomes useful to anyone. If anyone has suggestions or bug reports, I will look into it.

<img width="1553" height="1021" alt="image" src="https://github.com/user-attachments/assets/0285282d-1ded-4303-8d6c-d853d62a2d26" />

## Installation

1. Download the zip file from the GitHub Releases page.
2. Unzip it, and move it to your Applications folder.
3. This app is not signed (see FAQ). You will have to right click and press open, it fail, but don't move it to the trash.
4. Go into System Setting, then Privacy & Security, then find where it says Swan.app and `Open Anyway`, and press that.

## FAQ

**Q:** Why isn't Swan signed? What does that mean?

**A:** All apps you download on your Mac, before being run, typically need a digital "signature" from the developer. This proves that the app hasn't been corrupted or modified. But, to sign an app for Mac, you need a paid Apple Developer account. I have tried to obtain one, but for some reason, my account is blocked from creating a developer account. I do not know why, they have not told me, all I see is that "Your enrollment in the Apple Developer Program could not be completed at this time." This may be because of my work on Patched Sur, which allowed 2012-2013 unsupported Macs to run macOS Big Sur. If so, I am flattered. If this project, or any other future one of mine, gains enough traction, I will try harder to get an account, but it's not worth my time or money currently.

**Q:** How quickly will you update Swan?

**A:** I have learned to make no promises. I planned to release this publicly back in October 2025, and I could have done it earlier. This is mostly a static product for the time being, which will change if there's more interest or if someone has information on how to get access to more data. I do have other things going on in my life, and I have other projects, most of which do not see the light of day. This is a simple, useful utility I wrote that was worth making public. 

**Q:** Are there future plans for Swan?

**A:** Here are some of the ideas I've had for this:

- Browsing the other update catalogs (mesu.apple.com, gdmf.apple.com, among others)
- IPSW browsing support (complicated at best)
- Installer USB creation support
    - This could be useful for macOS Mojave and High Sierra that are more complicated than just the InstallAssistant.pkg
- Decreasing the amount of unknown types of entries in the list, like Printer Support or Font Assets

Again, this probably won't happen anytime soon unless there's interest. 
