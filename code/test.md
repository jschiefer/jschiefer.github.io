(*** raw ***)
---
layout: page
title: GNU/Linux system programming with F# and .Net Core
----

# Accessing Linux low-level libraries with F# and .Net Core
This blog post is part of the F# Advent Calendar. Check out the other awesome posts!

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

## Hey, what about Mono?

Glad you asked. Mono, an independent portable reimplmentation of the .Net
platform is also an option for running F#. At the time of this writing
(December 2016), the implementation of Mono is much more complete and usable
than .Net Core. It is also available on many more platforms than .Net Core
(e.g. various ARM variants). But .Net Core is new and shiny, and it has the
promise of being much more performant in the long run. It doesn't hurt to have
both of them installed, and use whatever you feel like. The mechanism described
below will work with either of them, as will the code in the github repo that
goes with this blog post.

## Our target: the RTL-SDR library

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
number of compatible devices detected. 

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
