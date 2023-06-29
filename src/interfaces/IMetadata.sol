//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


/* solhint-disable indent */

// enum metadatasource
enum MetadataSource {
    EXTERNAL, INTERNAL
}

struct Trait {
    string displayType;
    string key;
    string value;
}

struct MetadataContract {
    string _name;
    string _symbol;
    string _description;
    string _imageName;
    string[] _imageColors;
    string _externalUri;
    MetadataSource _metadataSource;
    string _baseUri;
}
