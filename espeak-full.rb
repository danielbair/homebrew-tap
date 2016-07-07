class Espeak1 < Formula
  desc "Text to speech, software speech synthesizer"
  homepage "http://espeak.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/espeak/espeak/espeak-1.48/espeak-1.48.04-source.zip"
  sha256 "bf9a17673adffcc28ff7ea18764f06136547e97bbd9edf2ec612f09b207f0659"

  conflicts_with "espeak",
                 :because => "both install the same binaries"
  conflicts_with "libespeak",
                 :because => "both install the same libraries"

  depends_on "portaudio"

  patch :DATA

  def install
    share.install "espeak-data"
    share.install "docs"
    cd "src" do
      rm "portaudio.h"
      system "make", "speak", "DATADIR=#{share}/espeak-data", "PREFIX=#{prefix}"
      bin.install "speak" => "espeak"
      system "make", "libespeak.a", "DATADIR=#{share}/espeak-data", "PREFIX=#{prefix}"
      lib.install "libespeak.a" => "libespeak.a"
      system "make", "libespeak.so", "DATADIR=#{share}/espeak-data", "PREFIX=#{prefix}"
      lib.install "libespeak.so.1.1.48" => "libespeak.dylib"
      system "install_name_tool", "-id", "#{lib}/libespeak.dylib", "#{lib}/libespeak.dylib"
    end
  end

  test do
    system "#{bin}/espeak", "This is a test for Espeak.", "-w", "out.wav"
  end
end
__END__
--- old/src/Makefile	2014-02-02 17:58:11.000000000 +0700
+++ new/src/Makefile	2016-07-01 07:23:59.000000000 +0700
@@ -16,7 +16,7 @@
 LIBTAG = $(LIB_VERSION).$(RELEASE)

 # Use SONAME_OPT=-Wl,h, on Solaris
-SONAME_OPT=-Wl,-soname,
+SONAME_OPT=-Wl,-install_name,

 # Use EXTRA_LIBS=-lm on Solaris
 EXTRA_LIBS =

--- old/src/event.cpp	2014-03-04 23:47:15.000000000 +0700
+++ new/src/event.cpp	2016-07-01 07:23:59.000000000 +0700
@@ -93,9 +93,9 @@
   pthread_mutex_init( &my_mutex, (const pthread_mutexattr_t *)NULL);
   init();

-  assert(-1 != sem_init(&my_sem_start_is_required, 0, 0));
-  assert(-1 != sem_init(&my_sem_stop_is_required, 0, 0));
-  assert(-1 != sem_init(&my_sem_stop_is_acknowledged, 0, 0));
+  //assert(-1 != sem_init(&my_sem_start_is_required, 0, 0));
+  //assert(-1 != sem_init(&my_sem_stop_is_required, 0, 0));
+  //assert(-1 != sem_init(&my_sem_stop_is_acknowledged, 0, 0));

   pthread_attr_t a_attrib;

@@ -406,18 +406,18 @@

 	add_time_in_ms( &ts, time_in_ms);

-	SHOW("polling_thread > sleep_until_timeout_or_stop_request > start sem_timedwait from %d.%09lu to %d.%09lu \n",
+	SHOW("polling_thread > sleep_until_timeout_or_stop_request > start sem_wait from %d.%09lu to %d.%09lu \n",
        to.tv_sec, to.tv_nsec,
        ts.tv_sec, ts.tv_nsec);

-	while ((err = sem_timedwait(&my_sem_stop_is_required, &ts)) == -1
+	while ((err = sem_wait(&my_sem_stop_is_required)) == -1
 		&& errno == EINTR)
 	{
 		continue; // Restart when interrupted by handler
 	}

 	assert (gettimeofday(&tv, NULL) != -1);
-	SHOW("polling_thread > sleep_until_timeout_or_stop_request > stop sem_timedwait %d.%09lu \n",
+	SHOW("polling_thread > sleep_until_timeout_or_stop_request > stop sem_wait %d.%09lu \n",
        tv.tv_sec, tv.tv_usec*1000);

 	if (err == 0)

--- old/src/fifo.cpp	2014-03-04 23:47:15.000000000 +0700
+++ new/src/fifo.cpp	2016-07-01 07:23:59.000000000 +0700
@@ -79,8 +79,8 @@
   pthread_mutex_init( &my_mutex, (const pthread_mutexattr_t *)NULL);
   init(0);

-  assert(-1 != sem_init(&my_sem_start_is_required, 0, 0));
-  assert(-1 != sem_init(&my_sem_stop_is_acknowledged, 0, 0));
+  //assert(-1 != sem_init(&my_sem_start_is_required, 0, 0));
+  //assert(-1 != sem_init(&my_sem_stop_is_acknowledged, 0, 0));

   pthread_attr_t a_attrib;
   if (pthread_attr_init (& a_attrib)
@@ -308,18 +308,18 @@

 		add_time_in_ms( &ts, INACTIVITY_TIMEOUT);

-		SHOW("fifo > sleep_until_start_request_or_inactivity > start sem_timedwait (start_is_required) from %d.%09lu to %d.%09lu \n",
+		SHOW("fifo > sleep_until_start_request_or_inactivity > start sem_wait (start_is_required) from %d.%09lu to %d.%09lu \n",
 			to.tv_sec, to.tv_nsec,
 			ts.tv_sec, ts.tv_nsec);

-		while ((err = sem_timedwait(&my_sem_start_is_required, &ts)) == -1
+		while ((err = sem_wait(&my_sem_start_is_required)) == -1
 			&& errno == EINTR)
 		{
 			continue;
 		}

 		assert (gettimeofday(&tv, NULL) != -1);
-		SHOW("fifo > sleep_until_start_request_or_inactivity > stop sem_timedwait (start_is_required, err=%d) %d.%09lu \n", err,
+		SHOW("fifo > sleep_until_start_request_or_inactivity > stop sem_wait (start_is_required, err=%d) %d.%09lu \n", err,
 			tv.tv_sec, tv.tv_usec*1000);

 		if (err==0)

