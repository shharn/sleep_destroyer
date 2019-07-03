import 'package:flutter/material.dart';

import 'package:sleep_destroyer/presentation/common.dart';
import 'package:sleep_destroyer/bloc/base.dart';
import 'package:sleep_destroyer/bloc/location.dart';
import 'package:sleep_destroyer/model/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sleep_destroyer/repository/file.dart';
import 'package:sleep_destroyer/repository/home.dart';
import 'package:sleep_destroyer/repository/location.dart';

class LocationSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = LocationBloc(homeRepository: HomeRepository(
      fileStorage: fileStorage),
      locationRepository: LocationRepository(fileStorage: fileStorage));
    return BlocProvider(
      bloc: bloc,
      child: MapViewContainer()
    );
  }
}

class MapViewContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: BlocProvider.of<LocationBloc>(context).location,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingIndicator();
        }

        final state = snapshot.data as LocationState;
        switch (state.runtimeType) {
          case LocationLoadingState:
            return LoadingIndicator();
          case LocationLoadSuccessState:
            return LocationPageBody(
              currentLocation: (state as LocationLoadSuccessState).currentLocation,
              storedLocation: (state as LocationLoadSuccessState).storedLocation
            );
          case LocationLoadFailureState:
            return Map(
              currentLocation: LatLng(37.42796133580664, -122.085749655962),
              storedLocation: Location.withDefault()
            );
        }
      }
    );
  }
}

class LocationPageBody extends StatelessWidget {
  LocationPageBody({
    this.currentLocation,
    this.storedLocation
  });

  final LatLng currentLocation;
  final Location storedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          StreamBuilder(
            stream: BlocProvider.of<LocationBloc>(context).locationSetOfHomeScreenMutation,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return ConfirmIconButton();
              }

              final state = snapshot.data as LocationMutationState;
              switch(state.runtimeType) {
                case LocationMutationWaitingState:
                  return LoadingIndicator();
                case LocationMutationSuccessState:
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                      debugPrint('[UpdatetimeSetOfHomeSuccessState] pop');
                      Navigator.pop(context);
                    });
                  return LoadingIndicator();
                case LocationMutationFailureState:
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    debugPrint('[UpdatetimeSetOfHomeSuccessState] pop');
                    Navigator.pop(context);
                  });
                  return LoadingIndicator();
                default:
                  return ConfirmIconButton();
              }
            }
          )
        ]
      ),
      body: Map(
        currentLocation: currentLocation,
        storedLocation: storedLocation,
      )
    );
  }
}

class ConfirmIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.done),
      onPressed: () => BlocProvider.of<LocationBloc>(context).updateLocationSetOfHomeScreen()
    );
  }
}

class Map extends StatefulWidget {
  Map({
    @required this.currentLocation,
    @required this.storedLocation
  });

  final LatLng currentLocation;
  final Location storedLocation;
  @override
  State<Map> createState() => MapState();
}

class MapState extends State<Map> {
  final _markerId = 'marker_id_1';

  Marker _marker;

  @override
  void initState() {
    super.initState();
    if (widget.storedLocation != null && widget.storedLocation.isValid) {
      _marker = Marker(
        markerId: MarkerId(_markerId),
        position: widget.storedLocation.toLatLng()
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = Set<Marker>();
    if (_marker != null) {
      markers.add(_marker);
    }
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.currentLocation,
        zoom: 18.0
      ),
      mapType: MapType.normal,
      myLocationEnabled: true,
      onTap: _onTap(context),
      markers: markers
    );
  }

  ArgumentCallback<LatLng> _onTap(BuildContext context) {
    return (LatLng tappedPosition) async  {
      debugPrint('tapped on ${tappedPosition.latitude} : ${tappedPosition.longitude}');
      final ok = await BlocProvider.of<LocationBloc>(context).saveLocation(Location.fromLatLng(tappedPosition));
      if (!ok) {
        final snackbar = SnackBar(content: Text('선택한 위치를 저장하는데 실패했습니다. 잠시 후 다시 시도해 주세요.'));
        Scaffold.of(context).showSnackBar(snackbar);
        return;
      }
      setState(() {
        _marker = Marker(
          markerId: MarkerId(_markerId),
          position: tappedPosition,
          onTap: () {
            setState(() => _marker = null);
          }
        );
      });
    };
  }
}