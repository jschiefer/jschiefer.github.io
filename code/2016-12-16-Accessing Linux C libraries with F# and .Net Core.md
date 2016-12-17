
This blog post is part of the F# Advent Calendar. Check out the other awesome posts!

There are many interesting native libraries available on the Linux platform,
which are usually accessed directly from C. While C is still a perfectly 
fine programming language for lower-level work, this is 2016, and we can do a little 
better. A lot better, actually. In this post I would like to show a few 
of the benefits that you gain when you use a modern "multi-paradigm" language
like F#, which allows you to write code in ways that you may not have seen before. 
I am assuming a working knowledge of C and Linux, but not much else.

"Waitwhat, isn't F# some Microsoft thing?" I hear you say. Yes, it came out of
Microsoft Research, but it has matured into an 
[OSS language](https://github.com/fsharp/fsharp) with an 
[Apache license](https://github.com/fsharp/fsharp/blob/master/LICENSE) and a
small-ish, but enthusiastic and friendly OSS community. F# compiles into
[Javascript](https://fable-compiler.github.io/) or the Microsoft .Net 
platform in one of its many incarnations. I will be focusing on the (somewhat
adolescent) [.Net Core](http://dot.net/core), because it has a lot of potential 
and is available on Linux, macOS and Windows.
One of the things .Net does really well is integrate with the underlying 
native platform, using a declarative mechanism called PInvoke. 
So even if you don't like Microsoft and the .Net platform
(and believe me, I used to be in that camp), please hold your nose and read on.
Or even better, install .Net Core for your platform (important: use the Long Term support
(LTS) version, open your shell,
cast the magic spell

    dotnet new --lang fsharp
    dotnet restore
    dotnet build
    dotnet run
    vi Program.fs

and follow along!

Did I just say "vi"? Sorry, old habits die hard. I should probably mention that
F# *greatly* benefits from a language-aware editor, which can offer assistance as
you work with your code. As F# is a strongly typed language, the editor can offer
quite a lot of help in identifying incorrect constructs before you even compile.
There are F# plugins 
[for all sorts of editors](http://fsharp.org/guides/mac-linux-cross-platform/#editing)
[(even Emacs!)](https://github.com/fsharp/emacs-fsharp-mode)). 
If you don't know where to start, try the excellent
[Visual Studio Code](https://code.visualstudio.com/) with the awesome
[Ionide-fsharp plugin](http://ionide.io/). And there are several vi plugins available for VS Code 
[(I use this one)](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim).

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

## Our target: the RTL-SDR library

One of my favourite underappreciated technologies in higher-level
programming platforms or languages is the way they interface with the native
language of the underlying OS.  Great examples are the Java Native Interface
(JNI) if the world of Java, the Simple Wrapper and Interface Generator (SWIG)
in Python or the Android NDK (Native Development Kit). Once you understand this
stuff and know where to look, not only will you be able to recognize the many
cases where the latest snazzy high-performance library turns out to be yet
another repackaging of the same old Fortran libraries (and I am not even
kidding), you will also be able to wrap your favorite libraries into
higher-level abstractions. 

I would like to shine a little light on these mechanisms using a recent arrival
on the GNU/Linux operating system, which is .Net Core. This is Microsoft's
attempt to become relevant on platforms other than Windows, and while they have
a little ways to go, the beginnings are promising. The most popular language on
the various .Net platforms is C#, and it is a great modern, expressive language
that in my opinion compares favorably with Java. But the real gem of the .Net
platform is F#, which is the same class of languages as Swift or Scala, in that
it does not force you into an object-oriented paradigm. So let's get started
with F# on GNU/Linux and you'll see what I mean!

## Hey, what about that Mono thing?


For this post, I will use the excellent rtl-sdr library as an example, which is
developed by the great people at Osmocom (a good overview is at
http://sdr.osmocom.org/trac/wiki/rtl-sdr). This is a library that supports a
class of very inexpensive USB-based devices for digital TV reception, and turns
them into a software-defined radio (SDR). This has all sorts of interesting
applications, and rtl-sdr is a great way to get started, at a very moderate
cost (the devices are widely available, at a cost of around USD 20). I don't
have room for an SDR primer, but in a nutshell it works as follows: Your
configure the center frequency of the receiver, and it begins to sample the
signals within a certain bandwidth around this center frequenct. These samples
are then delivered to a software application for further processing. This could
be for example to test whetehr there is a signal there at all. Or demodulate
it, in order to listen to the contents of the transmission.

To get the rtl-sdr library onto your system, you can either build it from
source, or install it from the package manager that comes with your distro. For
example, I am on Mint 17.3, so I just have to install librtlsdr-dev, which
pulls in all the relevant dependencies. One of these dependencies is libusb.
Look in your package manager for the equivalent library. 

OK, so what did we just install? This is a C libary we are talking about, so we
are looking for an include file (/usr/include/rtl-sdr.h on my system), and a
library (for me it is /usr/lib/x86_64-linux-gnu/librtlsdr.so). Oh, and as we
are talking to external hardware, the permissions need to be set right, which
is often done through /etc/udev. In my case, the package manager took care of
this. 

And while I am not talking here about macOS, librtlsdr-dev and its dependencies
are also available to install via Brew on the Mac, and all the code in this
post will work the same way. No, I didn't try Windows, but I am sure it can be
made to work in a similar manner.

## Talking to native libraries from F#

All right, we have the libary, now let's take a look on how to access it from
F#. The .Net platform has a mechanism called P/Invoke (for "Platform Invoke")
to access native libraries, which is surprisingly powerful. One nice element to
it is that with F#, it is purely declarative, which means that in most cases
all that is required to access a function from a native library is a simple
declaration, which also uses C syntax! Let's try this out.  The simplest
possible function that we can identify in the include file is the
`rtlsdr_get_device_count()` function: It takes no arguments and returns the
number of compatible devices detected. The exact declaration in the include file 
is `RTLSDR_API uint32_t rtlsdr_get_device_count(void)`. How do we translate this
into a declaration that we can use from F#? 

Here is some C:

    [lang=c]
    rtlsdr_get_device_count()

Here is some FSharp:

    let aa = rtlsdr_set_sample_rate(dev, 2560000u)
    let ab = rtlsdr_set_center_freq(dev, 1000000000u)
    let ac = rtlsdr_set_agc_mode(dev, 1)
    let bur = rtlsdr_reset_buffer(dev)
    printfn "rtlsdr_reset_buffer returned %A" bur

And even more:

    let data = 
        getAuctionPriceData() 
        |> Seq.map (fun x -> x.``UK time``, x.``30-11-2016``)

[explain corresponding data types, general declarations)]

[Native interop in dotnet core](https://docs.microsoft.com/en-us/dotnet/articles/standard/native-interop)

[example: number of devices]

`void blah()`

## Why bother with all this? 

If you are still with me, you may ask yourself, "why bother with all this, and
not write this code directly in C?" Excellent question, simpler is almost
always better. What F# gives you is the ability to work on higher levels of
abstraction. Often what you end up with is code that is substantially easier to
read and understand than C (and also to write, with a little practice). If you
have been interested in Software Defined Radio, you may have noticed that
practitioners in the field really seem to like block diagrams, and have devised
clever tools to write code that way (see for example Gnu Radio Companion). Why?
A block diagram gives you an appropriate abstraction to understand the signal
flow in the application, without pesky details like error handling getting in
the way of your higher level understanding. It is still there, but it is tucked
away where you don't need to look at it unless you want to.  F# gives you some
of the tools to separate out your abstractions, so you can get a similar effect
using textual programming.

Here's another lame analogy for you: Imagine cooking a meal in "cooking show
style"; rather than having some semi-hostile looking vegetables to deal with,
every ingredient is nicely peeled, chopped, and available for use in its own
little glass bowl. In my mind, programming with F# is like that: All the
ingredients are conveniently arranged for you to be creative with, and focus on
the outcome. True, it comes with investments (bowls) and some cost (washing
dishes), but the process is so much more enjoyable, which often leads to better
outcomes.

### Types without the typing! 

### Pipes without the, err... never mind

### Hide the ugly error handling!

### Agents!

### Units!!

## More F# Information

As you may or may not have gathered, the compiler is a powerful beast, and it
really pays to use its services when writing or editing source code. Regardless
of what your favorite editor is, there is probably F# support available, with
smart autocompletion, syntax highlighting and a lot of the other amenities that
you probably only have seen with full-blown IDEs like Eclipse or IntelliJ. If
you are not sure where to start, take a look at the excellent VS Code in
conjunction with the Ionide-FSharp plugin. Another option is monodevelop,
although the version that ships with your Linux distribution is probably way
too old.
