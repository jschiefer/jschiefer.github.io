What about Mono? I am glad you asked! 
[Mono, an independent portable reimplementation of the .Net platform](http://www.mono-project.com/)
is also an option for running F#. At the time of this writing
(December 2016), the implementation of Mono is much more complete and usable
than .Net Core. Mono is also available on many more processor architectures
(e.g. ARM). But .Net Core is new and shiny, and it has the
promise of being much more performant in the long run. It doesn't hurt to have
both of them installed, and use whatever you feel like. The mechanism described
below will work with either of them, as will the 
[code in the github repo that goes with this blog post](https://github.com/jschiefer/RadioLambda).

And if you prefer to work in a more full-featured IDE, I would recommend you take a look at the 
current version of [Monodevelop](http://www.monodevelop.com/), which has improved notably 
over the last year or so. It has gotten some love from Xamarin, who use it as the 
base for Xamarin Studio, now also known as "Visual Studio for Mac". Yep, that's
good old underappreciated Monodevelop under the hood.
Monodevelop has turned into a pleasant and capable IDE for F#. Some caveats: I don't think it
supports .Net Core yet, or at least not very well, so the code it produces would target
Mono. This might actually make things easier if you are just getting started. 
The version that comes with your distro is probably ancient, you want a version 6.x.
Also, the new Monodevelop releases for Linux use a shiny new distribution mechanism 
called [Flatpak](http://flatpak.org), 
which isn't supported on older Linux distros. You can always clone 
[the github repo](https://github.com/mono/monodevelop)
and build your own, which is what I ended up doing. 