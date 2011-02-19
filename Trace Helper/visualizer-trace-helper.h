#include <iostream>
#include <fstream>
#include "stdio.h"

#include "ns3/core-module.h"
#include "ns3/helper-module.h"
#include "ns3/node-module.h"
#include "ns3/simulator-module.h"
#include "ns3/mobility-module.h"
#include "ns3/wifi-module.h"
#include "ns3/output-stream-wrapper.h"
#include "ns3/ipv4-header.h"
#include "ns3/cross-layer-interface.h"
#include "ns3/resource-manager.h"

#ifndef __VISUALICER_TRACE_HELPER_H__
#define __VISUALICER_TRACE_HELPER_H__


/**
 * Helps with printing a valid trace file to be read by the Visualizer tool
 *
 * Minor changes added by Morten, for generic routing support, and added support for static positioned nodes, and hacked so that we periodically see store-carry-forward buffer size for each node...
 */
class VisualizerTraceHelper
{

public:

  typedef std::vector<ns3::GenericRoutingTableEntry>::const_iterator GenericTableIterator;

  /**
  * @brief Constructor of the class
  *
  * @param olsrVector Would really love to get rid of this parameter (TODO)
  *
  * Connects all needed sources with the corresponding sinks and initializes
  * everything
  */
  VisualizerTraceHelper (unsigned int simulationLengthInMilliseconds,
                         ns3::NodeContainer theNodeContainer);

  /**
  * @brief Destructor of the class
  */
  ~VisualizerTraceHelper ();

  /**
   * @brief Sink that handles a change in a node's course
   */
  void 
	CourseChanged(std::string context, ns3::Ptr<const ns3::MobilityModel> model);
	
	/**
	 * @brief Log the node role for the nodes in a NodeContainer
	 */
	void 
	LogNodeRole(ns3::NodeContainer nodeContainer, std::string nodeRole, uint32_t nodeIdStart);
	
  /**
   * @brief Sink that handles static positioned nodes
   */
  void 
	StaticPosition(int nodeId, int x, int y);

  /**
   * @brief Sink that handles a change in the routing table
   */
  void
  RouteChanged (std::string text, uint32_t size);

  /**
   * @brief Sink that handles a transmission in the MAC layer
   */
  void
  MacTransmit (std::string text, ns3::Ptr<const ns3::Packet> packet);

  /**
   * @brief Sink that handles a reception in the MAC layer
   */
  void
  MacReceive (std::string text, ns3::Ptr<const ns3::Packet> packet);

  /**
   * @brief Sink that handles a transmission in the MAC layer
   */
  void
  MacDrop (std::string text, ns3::Ptr<const ns3::Packet> packet);

  /**
   * @brief Sink that handles a transmission in the MAC layer
   */
  void
  QueueChange (std::string text, int nPackets);

  /**
   * @brief Periodically prints the no. of packets in buffers for each node. Added by Morten..
   */
  void
  PeriodicBufferSizeUpdate ();

  /**
   * @brief Prints the string passed as a parameter to the trace file 
   */
  void
  ManualTrace (std::string text);

  /**
   * @brief Tells the trace helper where and how to write the trace information
   */
  void
  StartWritingFile(std::string filename,std::ios::openmode filemode = std::ios::out);

  /**
   * @brief Tells the trace helper to stop writing into the trace file and closes
   * the output stream
   */
  void
  EndWritingFile();

protected:

  unsigned int simulationLength;

  ns3::NodeContainer nodeContainer;

  std::ofstream outputStream;
  
  /**
   * Connects all needed sources with the sinks in this class
   */
  void
  ConnectSinks();
  
  
  /**
   * Returns the id of a node, given its IP address.
   * Returns -1 if there is no such node
   *
   */
  int
  GetNodeIdForAddress(ns3::Ipv4Address address);
  
  /**
   * Returns the id of a node, given its MAC address.
   * Returns -1 if there is no such node
   *
   */
  int
  GetNodeIdForAddress(ns3::Mac48Address address);

};

#endif /* VISUALICER_TRACE_HELPER_H */

