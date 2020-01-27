import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/general_data.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:hasskit/helper/theme_info.dart';

class LocalLanguage {
  String languageCode;
  String countryCode;
  String displayName;
  String translator;

  LocalLanguage({
    @required this.languageCode,
    @required this.countryCode,
    @required this.displayName,
    @required this.translator,
  });
}

class LocalLanguagePicker extends StatefulWidget {
  @override
  _LocalLanguagePickerState createState() => _LocalLanguagePickerState();
}

class _LocalLanguagePickerState extends State<LocalLanguagePicker> {
  List<LocalLanguage> localLanguages = [
    LocalLanguage(
      languageCode: "en",
      countryCode: "US",
      displayName: "English",
      translator: "tuanha2000vn",
    ),
    LocalLanguage(
      languageCode: "sv",
      countryCode: "SE",
      displayName: "Swedish",
      translator: "Tyre88",
    ),
    LocalLanguage(
      languageCode: "vi",
      countryCode: "VN",
      displayName: "Vietnamese",
      translator: "tuanha2000vn",
    ),
    LocalLanguage(
      languageCode: "bg",
      countryCode: "BG",
      displayName: "Bulgarian",
      translator: "kirichkov",
    ),
    LocalLanguage(
      languageCode: "el",
      countryCode: "GR",
      displayName: "Greece",
      translator: "smartHomeHub",
    ),
    LocalLanguage(
      languageCode: "zh",
      countryCode: "CN",
      displayName:
          "Chinese Simplified", //Simplified Chinese or 中文简体 (zh-CN) is used in China. Traditional Chinese or 中文繁体 (zh-TW) is used in Taiwan
      translator: "thor",
    ),
    LocalLanguage(
      languageCode: "zh",
      countryCode: "TW",
      displayName:
          "Chinese Traditional", //Simplified Chinese or 中文简体 (zh-CN) is used in China. Traditional Chinese or 中文繁体 (zh-TW) is used in Taiwan
      translator: "bluefoxlee",
    ),
    LocalLanguage(
      languageCode: "ru",
      countryCode: "RU",
      displayName: "Russian",
      translator: "antropophob",
    ),
    LocalLanguage(
      languageCode: "nl",
      countryCode: "NL",
      displayName: "Dutch",
      translator: "Arjan",
    ),
    LocalLanguage(
      languageCode: "he",
      countryCode: "IL",
      displayName: "Hebrew",
      translator: "Asaf",
    ),
    LocalLanguage(
      languageCode: "hu",
      countryCode: "HU",
      displayName: "Hungarian",
      translator: "A320Peter",
    ),
    LocalLanguage(
      languageCode: "pt",
      countryCode: "PT",
      displayName: "Portuguese",
      translator: "Rui Duarte",
    ),
    LocalLanguage(
      languageCode: "fr",
      countryCode: "FR",
      displayName: "French",
      translator: "QuentinBens",
    ),
    LocalLanguage(
      languageCode: "de",
      countryCode: "DE",
      displayName: "Deutsch",
      translator: "Steckenpferd",
    ),
    LocalLanguage(
      languageCode: "pl",
      countryCode: "PL",
      displayName: "Polish",
      translator: "Simoncheeseman",
    ),
    LocalLanguage(
      languageCode: "it",
      countryCode: "IT",
      displayName: "Italian",
      translator: "Niccolo",
    ),
    LocalLanguage(
      languageCode: "es",
      countryCode: "ES",
      displayName: "Spanish",
      translator: "Jotacor",
    ),
    LocalLanguage(
      languageCode: "uk",
      countryCode: "UA",
      displayName: "Ukrainian",
      translator: "AndreiRadchenko",
    ),
  ];

  @override
  void initState() {
    super.initState();
    localLanguages.sort((a, b) => (a.displayName).compareTo(b.displayName));
  }

  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    var localizations = Localizations.localeOf(context);
    var selectedValue;

    if (data.savedLocale != null) {
      selectedValue =
          "${data.savedLocale.languageCode}_${data.savedLocale.countryCode}";
    } else {
      selectedValue =
          "${localizations.languageCode}_${localizations.countryCode}";
    }

//    log.d("data.savedLocale ${data.savedLocale}");
//    log.d("localizations $localizations");
//    log.d("selectedValue $selectedValue");

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8)),
            child: DropdownButton<String>(
              value: selectedValue,
              underline: Container(),
              isExpanded: true,
              isDense: true,
              items: localLanguages.map((LocalLanguage map) {
                return DropdownMenuItem<String>(
                  value: "${map.languageCode}_${map.countryCode}",
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 26),
                      Text(
                        gd.textToDisplay(
                            "${map.displayName} - © ${map.translator}"),
                        style: Theme.of(context).textTheme.body1,
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: gd.textScaleFactorFix,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  var languageCode = newValue.split("_")[0];
                  var countryCode = newValue.split("_")[1];
                  log.d(
                      "newValue $newValue languageCode $languageCode countryCode $countryCode");
                  data.changeLocale(Locale(
                    languageCode,
                    countryCode,
                  ));
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
