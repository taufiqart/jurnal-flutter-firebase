// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, file_names

import 'package:e_jupe_skensa/components/Button.dart';
import 'package:e_jupe_skensa/config/variable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // custom color statusbar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
    );
    // end

    // get screen size
    var screen = MediaQuery.of(context).size;
    // end
    return Scaffold(
      body: Container(
        width: screen.width,
        height: screen.height,
        // background gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientPrimary,
            transform: GradientRotation(40),
          ),
        ),
        // end
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: screen.width,
                    height: screen.height * 0.42,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              logo,
                              height: 50,
                            ),
                            SizedBox(
                              width: 17,
                            ),
                            Text(
                              nameApp,
                              style: GoogleFonts.poppins(
                                fontWeight: semibold,
                                color: textPrimary,
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deskripsiApp,
                                overflow: TextOverflow.fade,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: semibold,
                                  textBaseline: TextBaseline.alphabetic,
                                  color: textPrimary,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                sloganApp,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screen.width,
                    height: screen.height * 0.47,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(50),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // import buttom from components button
                        Button(
                          onPress: () =>
                              {Navigator.pushNamed(context, signupRoute)},
                          width: screen.width * 0.8,
                          height: screen.height * 0.06,
                          borderRadius: BorderRadius.circular(10),
                          colors: const [Colors.blue, Colors.blue],
                          borderWidth: 1.5,
                          child: Text(
                            signupText,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: semibold,
                            ),
                          ),
                        ),
                        // end

                        // add space from button daftar and button masuk
                        SizedBox(
                          height: 10,
                        ),
                        // end

                        // button masuk
                        Button(
                          onPress: () =>
                              {Navigator.pushNamed(context, loginRoute)},
                          width: screen.width * 0.8,
                          height: screen.height * 0.06,
                          borderRadius: BorderRadius.circular(10),
                          type: BtnType.border,
                          borderWidth: 1.5,
                          child: Text(
                            loginText,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.blue,
                              fontWeight: semibold,
                            ),
                          ),
                        ),
                        // add space from button masuk and text bottom
                        SizedBox(
                          height: 40,
                        ),
                        // end

                        // container text bottom
                        Container(
                          width: screen.width * 0.7,
                          child: Text(
                            infoOnboardingText,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // end

                        // add space from text to bottom
                        SizedBox(
                          height: 40,
                        )
                        // end
                      ],
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: screen.width,
                    height: screen.height * 0.6,
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      calendar,
                      width: screen.width * 0.8,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
